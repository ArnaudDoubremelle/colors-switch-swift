//
//  GameScene.swift
//  ColorsSwitch
//
//  Created by Baptiste BRIOIS on 19/06/2018.
//  Copyright © 2018 ADBB. All rights reserved.
//

import SpriteKit

enum PlayColors {
    static let colors = [
        UIColor(red: 236/255, green: 99/255, blue: 74/255, alpha: 1.0),
        UIColor(red: 231/255, green: 199/255, blue: 0/255, alpha: 1.0),
        UIColor(red: 93/255, green: 178/255, blue: 60/255, alpha: 1.0),
        UIColor(red: 66/255, green: 136/255, blue: 200/255, alpha: 1.0),
    ]
}

enum SwitchState: Int {
    case red, yellow, green, blue
}

class GameScene: SKScene {
    
    var colorSwitch: SKSpriteNode!
    var switchState = SwitchState.red
    var currentColorIndex: Int?
    var limitZone: SKShapeNode!
    
    let scoreLabel = SKLabelNode(text: "0")
    var score = 0
    var xGravity = ((Double(arc4random()) / 0xFFFFFFFF) * (1.2)) - 0.6
    var yGravity: Double = -2.0
    var startLocation: CGPoint!
    
    override func didMove(to view: SKView) {
        setupPhysics()
        layoutScene()
    }
    
    func setupPhysics() {
        physicsWorld.gravity = CGVector(dx: xGravity, dy: yGravity)
        physicsWorld.contactDelegate = self
    }
    
    func layoutScene() {
        backgroundColor = UIColor(red: 33/255, green: 33/255, blue: 33/255, alpha: 1.0)
        
        colorSwitch = SKSpriteNode(imageNamed: "ColorCircle")
        colorSwitch.size = CGSize(width: frame.size.width/3, height: frame.size.width/3)
        colorSwitch.position = CGPoint(x: frame.midX, y: frame.minY + colorSwitch.size.height)
        colorSwitch.zPosition = ZPositions.colorSwitch
        colorSwitch.physicsBody = SKPhysicsBody(circleOfRadius: colorSwitch.size.width/2)
        colorSwitch.physicsBody?.categoryBitMask = PhysicsCategories.switchCategory
        colorSwitch.physicsBody?.isDynamic = false
        addChild(colorSwitch)
        
        limitZone = SKShapeNode(rectOf: CGSize(width: frame.size.width, height: 10))
        limitZone.lineWidth = 0
        limitZone.position = CGPoint(x: frame.midX, y: frame.minY + colorSwitch.size.height/2)
        limitZone.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: frame.size.width, height: 10))
        limitZone.physicsBody?.categoryBitMask = PhysicsCategories.limitCategory
        limitZone.physicsBody?.isDynamic = false
        addChild(limitZone)
        
        scoreLabel.fontName = "AvenirNext-Bold"
        scoreLabel.fontSize = 40.0
        scoreLabel.fontColor = UIColor.white
        scoreLabel.position = CGPoint(x: frame.maxX - 40, y: frame.midY - 15)
        scoreLabel.zPosition = ZPositions.label
        addChild(scoreLabel)
        
        let logo = SKSpriteNode(imageNamed: "logo")
        logo.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(logo)
        
        spawnBall()
    }
    
    func updateScoreLabel() {
        scoreLabel.text = "\(score)"
    }
    
    func spawnBall() {
        currentColorIndex = Int(arc4random_uniform(UInt32(4)))
        
        let ball = SKSpriteNode(texture: SKTexture(imageNamed: "ball"), color: PlayColors.colors[currentColorIndex!], size: CGSize(width: 30.0, height: 30.0))
        ball.colorBlendFactor = 1.0
        ball.name = "Ball"
        ball.position = CGPoint(x: frame.midX, y: frame.maxY)
        ball.zPosition = ZPositions.ball
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width/2)
        ball.physicsBody?.categoryBitMask = PhysicsCategories.ballCategory
        ball.physicsBody?.contactTestBitMask = PhysicsCategories.switchCategory | PhysicsCategories.limitCategory
        ball.physicsBody?.collisionBitMask = PhysicsCategories.none
        addChild(ball)
    }
    
    func turnWheel() {
        if let newState = SwitchState(rawValue: switchState.rawValue + 1) {
            switchState = newState
        } else {
            switchState = .red
        }
        
        colorSwitch.run(SKAction.rotate(byAngle: .pi/2, duration: 0.25))
    }
    
    func gameOver() {
        UserDefaults.standard.set(score, forKey: "RecentScore")
        if score > UserDefaults.standard.integer(forKey: "Highscore") {
            UserDefaults.standard.set(score, forKey: "Highscore")
        }
        
        let menuScene = MenuScene(size: view!.bounds.size)
        view!.presentScene(menuScene)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        startLocation = colorSwitch.position
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        let touch: UITouch = touches.first!
        let location = touch.location(in: self)
        
        colorSwitch.position = CGPoint(x: location.x, y: frame.minY + colorSwitch.size.height)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        let touch: UITouch = touches.first!
        let location = touch.location(in: self)
        
        if ((startLocation.x - 20) < location.x && location.x < (startLocation.x + 20)) {
            turnWheel()
        }
    }
}

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if contactMask == PhysicsCategories.ballCategory | PhysicsCategories.switchCategory {
            if let ball = contact.bodyA.node?.name == "Ball" ? contact.bodyA.node as? SKSpriteNode : contact.bodyB.node as? SKSpriteNode {
                if currentColorIndex == switchState.rawValue {
                    run(SKAction.playSoundFileNamed("success_" + "\(currentColorIndex ?? 0)", waitForCompletion: false))
                    score += 1
                    xGravity = ((Double(arc4random()) / 0xFFFFFFFF) * (1.0)) - 0.5
                    yGravity -= score%10 == 0 ? 1.0 : 0.0
                    setupPhysics()
                    updateScoreLabel()
                    ball.physicsBody = SKPhysicsBody()
                    ball.run(SKAction.fadeOut(withDuration: 0.25), completion: {
                        ball.removeFromParent()
                        self.spawnBall()
                    })
                } else {
                    gameOver()
                }
            }
        } else if contactMask == PhysicsCategories.ballCategory | PhysicsCategories.limitCategory {
            gameOver()
        }
    }
}

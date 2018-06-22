//
//  GameViewController.swift
//  ColorsSwitch
//
//  Created by Baptiste BRIOIS on 19/06/2018.
//  Copyright © 2018 ADBB. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            let scene = MenuScene(size: view.bounds.size)
                
            // Set the scale mode to scale to fit the window
            scene.scaleMode = .aspectFill
            
            // Present the scene
            view.presentScene(scene)
            
            view.ignoresSiblingOrder = true
            
            view.showsPhysics = false
            view.showsFPS = false
            view.showsNodeCount = false
        }
    }
}

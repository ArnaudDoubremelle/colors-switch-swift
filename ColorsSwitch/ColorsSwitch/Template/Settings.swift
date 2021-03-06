//
//  Settings.swift
//  ColorsSwitch
//
//  Created by Baptiste BRIOIS on 20/06/2018.
//  Copyright © 2018 ADBB. All rights reserved.
//

import SpriteKit

enum PhysicsCategories {
    static let none: UInt32 = 0
    static let ballCategory: UInt32 = 0x1           // 01
    static let switchCategory: UInt32 = 0x1 << 1    // 02
    static let limitCategory: UInt32 = 0x1 << 2     // 04
}

enum ZPositions {
    static let label: CGFloat = 0
    static let ball: CGFloat = 1
    static let colorSwitch: CGFloat = 2
}

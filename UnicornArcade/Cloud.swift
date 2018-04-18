//
//  Cloud.swift
//  UnicornArcade
//
//  Created by Daniel Alarcon on 4/18/18.
//  Copyright © 2018 NYU_iOS_Programming_Team. All rights reserved.
//


import UIKit
import SpriteKit

class Cloud: SKSpriteNode {
    var invaderRow = 0
    var invaderColumn = 0
    
    init(){
        let texture = SKTexture(imageNamed: "invader1")
        super.init(texture: texture, color: SKColor.clear, size: texture.size())
        self.name = "invader"
        self.physicsBody =
            SKPhysicsBody(texture: self.texture!, size: self.size)
        self.physicsBody?.isDynamic = true
        self.physicsBody?.usesPreciseCollisionDetection = true
        self.physicsBody?.categoryBitMask = CollisionCategories.Obstacle
        self.physicsBody?.contactTestBitMask = CollisionCategories.Player
        self.physicsBody?.collisionBitMask = 0x0
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}

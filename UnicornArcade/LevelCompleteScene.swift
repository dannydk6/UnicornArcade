//
//  LevelCompleteScene.swift
//  UnicornArcade
//
//  Created by Daniel Alarcon on 4/9/18.
//  Copyright © 2018 NYU_iOS_Programming_Team. All rights reserved.
//

import UIKit
import SpriteKit

class LevelCompleteScene:SKScene{
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.black
        let startGameButton = SKSpriteNode(imageNamed: "nextlevelbtn")
        
        // Get the image's aspect ratio
        let aspect = startGameButton.size.width/startGameButton.size.height
        let newWidth = size.width/1.4
        startGameButton.size = CGSize(width: newWidth, height: newWidth/aspect)
        startGameButton.position = CGPoint(x: size.width/2, y: size.height/2 - 100)
        startGameButton.name = "nextlevel"
        addChild(startGameButton)
        NSLog("We have loaded the next level screen")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Unwrap to UITouch object
        let touch = touches.first!
        let touchLocation = touch.location(in: self)
        let touchedNode = self.nodes(at: touchLocation).first
        
        // Check if the node we touched is a sprite node
        if ((touchedNode as? SKSpriteNode) != nil) {
            // If it is a sprite node, make sure it is the next level button
            if(touchedNode?.name == "nextlevel"){
                let gameOverScene = GameScene(size: size)
                gameOverScene.scaleMode = scaleMode
                let transitionType = SKTransition.flipHorizontal(withDuration: 1.0)
                view?.presentScene(gameOverScene, transition: transitionType)
                
            }
        }
    }
}

//
//  Player.swift
//  UnicornArcade
//
//  Created by Daniel Alarcon on 4/8/18.
//  Copyright © 2018 NYU_iOS_Programming_Team. All rights reserved.
//

import UIKit
import SpriteKit

class Player: SKSpriteNode {
    
    private var canFire = true
    private var sprite = "unicorn"
    private var timePerFrame = 0.35
    
    private var invincible = false
    
    private var lives:Int = 3 {
        didSet {
            if(lives < 0){
                kill()
            }else{
                respawn()
            }
        }
    }
    
    init() {
        // Sets the player's character sprite.
        let texture = SKTexture(imageNamed: sprite+String(1))
        
        super.init(texture: texture, color: SKColor.clear, size: texture.size())
        
        // Initialize the character's physics.
        self.physicsBody =
            SKPhysicsBody(texture: self.texture!,size:self.size)
        self.physicsBody?.isDynamic = true
        self.physicsBody?.usesPreciseCollisionDetection = false
        
        // Sets the collision category the player is in
        self.physicsBody?.categoryBitMask = CollisionCategories.Player
        
        // Sets what the player can collide with
        self.physicsBody?.contactTestBitMask = CollisionCategories.InvaderBullet | CollisionCategories.Invader
        
        // Sets the collision bit mask so the player doesn't jump out of screen.
        self.physicsBody?.collisionBitMask = CollisionCategories.EdgeBody
        
        // Do not rotate sprite on collision
        self.physicsBody?.allowsRotation = false
        self.setScale(0.75);
        animate()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func animate(){
        var playerTextures:[SKTexture] = []
        for i in 1...2 {
            playerTextures.append(SKTexture(imageNamed: sprite+String(i)))
        }
        let playerAnimation = SKAction.repeatForever( SKAction.animate(with: playerTextures, timePerFrame: timePerFrame))
        self.run(playerAnimation)
    }
    
    
    func die (){
        if(invincible == false){
            lives -= 1
        }
    }
    
    func kill(){
        invaderNum = 1
        let gameOverScene = StartGameScene(size: self.scene!.size)
        gameOverScene.scaleMode = self.scene!.scaleMode
        let transitionType = SKTransition.flipHorizontal(withDuration: 0.5)
        self.scene!.view!.presentScene(gameOverScene,transition: transitionType)
    }
    
    func respawn(){
        invincible = true
        let fadeOutAction = SKAction.fadeOut(withDuration: 0.4)
        let fadeInAction = SKAction.fadeIn(withDuration: 0.4)
        let fadeOutIn = SKAction.sequence([fadeOutAction,fadeInAction])
        let fadeOutInAction = SKAction.repeat(fadeOutIn, count: 3)
        let setInvicibleFalse = SKAction.run(){
            self.invincible = false
        }
        run(SKAction.sequence([fadeOutInAction,setInvicibleFalse]))
        
    }
    
    func fireBullet(scene: SKScene){
        if(!canFire){
            return
        }else{
            canFire = false
            let bullet = PlayerBullet(imageName: "laser",bulletSound: "laser.mp3")
            bullet.position.x = self.position.x
            bullet.position.y = self.position.y + self.size.height/2
            scene.addChild(bullet)
            let moveBulletAction = SKAction.move(to: CGPoint(x:self.position.x,y:scene.size.height + bullet.size.height), duration: 1.0)
            let removeBulletAction = SKAction.removeFromParent()
            bullet.run(SKAction.sequence([moveBulletAction,removeBulletAction]))
            let waitToEnableFire = SKAction.wait(forDuration: 0.3)
            run(waitToEnableFire,completion:{
                self.canFire = true
            })
        }
    }
}

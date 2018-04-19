//
//  GameScene.swift
//  UnicornArcade
//
//  Created by Daniel Alarcon on 4/8/18.
//  Copyright © 2018 NYU_iOS_Programming_Team. All rights reserved.
//

import SpriteKit
import CoreMotion

var invaderNum = 1

// Collision  Categories are bitmasks that count as a collision type.
struct CollisionCategories{
    static let Invader : UInt32 = 0x1 << 0
    static let Player: UInt32 = 0x1 << 1
    static let InvaderBullet: UInt32 = 0x1 << 2
    static let PlayerBullet: UInt32 = 0x1 << 3
    static let EdgeBody: UInt32 = 0x1 << 4
    static let Obstacle: UInt32 = 0x1 << 5
}

// The main game scene. Acts as a delegate for physics collisions.
class GameScene: SKScene, SKPhysicsContactDelegate {
    // How many points per second the unicorn should travel
    let speedPPS = CGFloat(300)
    let rowsOfInvaders = 3
    var invaderSpeed = 2
    let leftBounds = CGFloat(30)
    var rightBounds = CGFloat(0)
    var invadersWhoCanFire = [Invader]()  //changed invadersWhoCanFire:[Invader]
    let player = Player() //changed player:Player
    let maxLevels = 3
    let motionManager: CMMotionManager = CMMotionManager()
    var accelerationX: CGFloat = 0.0
    
    //to hold if we already added one cloud for a cloud we are going to replace
    var didAlreadyAddCloud = [Bool]();
    
    var clouds = [Cloud]();
    
    let moveCloudDownBy = 5;
    
    // This code is run when the view is switched in to.
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.black
        let starField = SKEmitterNode(fileNamed: "StarField")
        starField?.position = CGPoint(x:size.width/2,y:size.height/2)
        starField?.zPosition = -1000
        addChild(starField!)
        
        // The gravity and contact delegate must be set.
        self.physicsWorld.gravity = CGVector(dx:0,dy:0)
        self.physicsWorld.contactDelegate = self
        
        // Set the boundaries
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        self.physicsBody?.categoryBitMask = CollisionCategories.EdgeBody
        
        // Sets view bg color
        backgroundColor = SKColor.black
    
        rightBounds = self.size.width - 30
        setupInvaders()
        setupPlayer()
        //invokeInvaderFire()
        setupAccelerometer()
        
        //add initial cloud to scene
        setupCloud();
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Called when a touch begins */
        self.player.fireBullet(scene: self)
        
        
        // Unwrap to UITouch object
        let touch = touches.first!
        let touchLocation = touch.location(in: self)
        print("Touch Location \(touchLocation.x), \(touchLocation.y)")
        
        let duration = (squareNum(number: (touchLocation.x - self.player.position.x)).squareRoot())/speedPPS
        let move = SKAction.move(to: CGPoint(x: touchLocation.x,y: self.player.position.y), duration:TimeInterval(duration))
        self.player.run(move)
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
        
        //Edited out move invaders for testing purposes
        //moveInvaders()
        moveClouds()
        checkClouds()
    }
    
    // Add a cloud to the scene, and set intial position.
    func setupCloud() {
        
        let tempCloud:Cloud = Cloud();
        
        let screenSize = UIScreen.main.bounds;
        let screenWidth = screenSize.width;
        let screenHeight = screenSize.height;

        //generate a random location on the screen to place cloud
        //
        let cloudLocationX = arc4random_uniform(UInt32(screenWidth));
        let cloudLocationY = UInt32(screenHeight) + 30;
        
        //position cloud
        tempCloud.position = CGPoint(x: CGFloat(cloudLocationX), y: CGFloat(cloudLocationY));
        
        //add cloud to scene;
        addChild(tempCloud);
        
        //add cloud to array of clouds (currently on the view)
        clouds.append(tempCloud);
        
        //index will corelate with cloud its describing in clouds array
        didAlreadyAddCloud.append(false);
        

    }
    
    //moves all clouds in the scene
    func moveClouds() {
        
        //subtract from y cordinate to move cloud down screen
        for cloud in clouds {
            let currentPosition = cloud.position;
            let currentY = currentPosition.y;
            
            let newY = currentY - CGFloat(moveCloudDownBy);
            
            cloud.position = CGPoint(x: currentPosition.x, y: newY);
        }
    }

    //checks clouds, to see if we need to add another cloud to screen and if we need to delete any clouds currently on view
    func checkClouds() {
        
        let deleteCondition = -20;
        let addCondition = 150;
        
        //print(clouds.count);
        
        for cloud in clouds {
            let currentPosition = cloud.position;
            
            //if cloud is out of view remove it
            if (currentPosition.y <= CGFloat(deleteCondition)) {
                deleteCloud(cloudToRemove: cloud);
            }
            //if cloud close to being out of view, add another cloud
            else if (currentPosition.y <= CGFloat(addCondition)) {

                if let index = clouds.index(of: cloud) {
                    if (didAlreadyAddCloud[index] == false) {
                        didAlreadyAddCloud[index] = true;
                        setupCloud();
                    }
                    
                }
            }
        }
        
    }
    
    //removes cloud node from clouds array from and the boolean corresponding value in didAlreadyAddCloud
    func deleteCloud(cloudToRemove: Cloud) {
        
        cloudToRemove.removeFromParent();
        
        if let index = clouds.index(of: cloudToRemove) {
            clouds.remove(at: index)
            didAlreadyAddCloud.remove(at: index);
        }

    }

    
    
    // Positions the rows and columns of invaders on the screen.
    func setupInvaders(){
        var invaderRow = 0;
        var invaderColumn = 0;
        let numberOfInvaders = invaderNum * 2 + 1
        for i in 1...rowsOfInvaders {
            invaderRow = i
            for j in 1...numberOfInvaders {
                invaderColumn = j
                let tempInvader:Invader = Invader()
                let invaderHalfWidth:CGFloat = tempInvader.size.width/2
                let xPositionStart:CGFloat = size.width/2 - invaderHalfWidth - (CGFloat(invaderNum) * tempInvader.size.width) + CGFloat(10)
                tempInvader.position = CGPoint(x:xPositionStart + ((tempInvader.size.width+CGFloat(10))*(CGFloat(j-1))), y:CGFloat(self.size.height - CGFloat(i) * 46))
                tempInvader.invaderRow = invaderRow
                tempInvader.invaderColumn = invaderColumn
                addChild(tempInvader)
                if(i == rowsOfInvaders){
                    invadersWhoCanFire.append(tempInvader)
                }
            }
        }
    }
    
    // Initiate the player character at the bottom of the screen.
    func setupPlayer(){
        player.position = CGPoint(x:self.frame.midX, y:player.size.height/2 + 10)
        addChild(player)
    }
    
    // Move the invades left to right, down, then right to left on repeat.
    func moveInvaders(){
        var changeDirection = false
        // For each invader,
        enumerateChildNodes(withName: "invader") { node, stop in
            let invader = node as! SKSpriteNode
            let invaderHalfWidth = invader.size.width/2
            invader.position.x -= CGFloat(self.invaderSpeed)
            if(invader.position.x > self.rightBounds - invaderHalfWidth || invader.position.x < self.leftBounds + invaderHalfWidth){
                changeDirection = true
            }
            
        }
        
        if(changeDirection == true){
            self.invaderSpeed *= -1
            self.enumerateChildNodes(withName: "invader") {
                node, stop in
                let invader = node as! SKSpriteNode
                invader.position.y -= CGFloat(24)
            }
            changeDirection = false
        }
        
    }
    
    // Set up an action to fire bullets from the invaders for the entire game loop.
    func invokeInvaderFire(){
        let fireBullet = SKAction.run(){
            self.fireInvaderBullet()
        }
        let waitToFireInvaderBullet = SKAction.wait(forDuration: 1.5)
        let invaderFire = SKAction.sequence([fireBullet,waitToFireInvaderBullet])
        let repeatForeverAction = SKAction.repeatForever(invaderFire)
        run(repeatForeverAction)
    }
    
    // Choose a random invader who is in front column and have him shoot a laser at player
    func fireInvaderBullet(){
        if(invadersWhoCanFire.isEmpty){
            invaderNum += 1
            levelComplete()
        }else{
            let randomInvader = invadersWhoCanFire.randomElement()
            randomInvader.fireBullet(scene: self)
        }
    }
    
    // Function is called when two physics bodies collide.
    func didBegin(_ contact: SKPhysicsContact) {
        
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if ((firstBody.categoryBitMask & CollisionCategories.Invader != 0) &&
            (secondBody.categoryBitMask & CollisionCategories.PlayerBullet != 0)){
            if (contact.bodyA.node?.parent == nil || contact.bodyB.node?.parent == nil) {
                return
            }
            let invadersPerRow = invaderNum * 2 + 1
            let theInvader = firstBody.node as! Invader
            let newInvaderRow = theInvader.invaderRow - 1
            let newInvaderColumn = theInvader.invaderColumn
            if(newInvaderRow >= 1){
                self.enumerateChildNodes(withName: "invader") { node, stop in
                    let invader = node as! Invader
                    if invader.invaderRow == newInvaderRow && invader.invaderColumn == newInvaderColumn{
                        self.invadersWhoCanFire.append(invader)
                        stop.pointee = true
                    }
                }
            }
            let invaderIndex = findIndex(array: invadersWhoCanFire,valueToFind: firstBody.node as! Invader)
            if(invaderIndex != nil){
                invadersWhoCanFire.remove(at:invaderIndex!)
            }
            theInvader.removeFromParent()
            secondBody.node?.removeFromParent()
        }
        
        if ((firstBody.categoryBitMask & CollisionCategories.Player != 0) &&
            (secondBody.categoryBitMask & CollisionCategories.InvaderBullet != 0)) {
            player.die()
        }
        
        if ((firstBody.categoryBitMask & CollisionCategories.Invader != 0) &&
            (secondBody.categoryBitMask & CollisionCategories.Player != 0)) {
            NSLog("Invader and Player Collision Contact")
            player.kill()
        }
        
        if ((firstBody.categoryBitMask & CollisionCategories.Player != 0) &&
            (secondBody.categoryBitMask & CollisionCategories.Obstacle != 0)) {
            player.die()
        }
        
    }
    
    func levelComplete(){
        if(invaderNum <= maxLevels){
            let levelCompleteScene = LevelCompleteScene(size: size)
            levelCompleteScene.scaleMode = scaleMode
            let transitionType = SKTransition.flipHorizontal(withDuration: 0.5)
            view?.presentScene(levelCompleteScene,transition: transitionType)
        }else{
            invaderNum = 1
            newGame()
        }
    }
    
    func newGame(){
        let gameOverScene = StartGameScene(size: size)
        gameOverScene.scaleMode = scaleMode
        let transitionType = SKTransition.flipHorizontal(withDuration: 0.5)
        view?.presentScene(gameOverScene,transition: transitionType)
    }
    
    func setupAccelerometer(){
        motionManager.accelerometerUpdateInterval = 0.2
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!){ (data, error) in
            if let accelerometerData = data
            {
                let acceleration = accelerometerData.acceleration
                self.accelerationX = CGFloat(acceleration.x)
            }
            
        }
    }
    
    override func didSimulatePhysics() {
        player.physicsBody?.velocity = CGVector(dx: accelerationX * 600, dy: 0)
    }
}

func findIndex<T: Equatable>(array: [T], valueToFind: T) -> Int? {
    for (index, value) in array.enumerated() {
        if value == valueToFind {
            return index
        }
    }
    return nil
}


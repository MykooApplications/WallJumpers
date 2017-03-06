//
//  GameScene.swift
//  WallJumpers
//
//  Created by Roshan Mykoo on 3/2/17.
//  Copyright © 2017 Roshan Mykoo. All rights reserved.
//

import SpriteKit
import GameplayKit

struct physicsCategories {
    static let wallCategory: UInt32 = 0x1<<2
    static let leftWallName:String = "leftWall"
    static let rightWallCategory: UInt32 = 0x1<<2
    static let rightWallName:String = "rightWall"
    
    static let playerCategory: UInt32 = 0x1<<0
    static let playerName:String = "player"
    
    static let spikeCategory: UInt32 = 0x1<<1
    static let spikeName:String = "spike"
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let startSoundAction: SKAction = SKAction.playSoundFileNamed("levelUp", waitForCompletion: true)
    let jumpSoundAction: SKAction = SKAction.playSoundFileNamed("jump", waitForCompletion: true)
    
    
    
    func createGame() {
        self.physicsWorld.contactDelegate = self
        
        //boarder
        let boarder = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody = boarder
        
        //Setting up Score Label
        
        
        //Setting up Left wall
        let leftWall = SKSpriteNode()
        leftWall.name = physicsCategories.leftWallName
        leftWall.position = CGPoint(x: 0.0, y: self.frame.midY)
        leftWall.size.width = 100.0
        leftWall.size.height = 736
        leftWall.color = UIColor.blue
        leftWall.physicsBody = SKPhysicsBody(rectangleOf: leftWall.frame.size)
        leftWall.physicsBody?.restitution = 0.0
        leftWall.physicsBody?.friction = 0.0
        leftWall.physicsBody?.isDynamic = false
        leftWall.physicsBody?.categoryBitMask = physicsCategories.wallCategory
        self.addChild(leftWall)
        
        
        //Setting up Right wall
        let rightWall = SKSpriteNode()
        rightWall.name = physicsCategories.rightWallName
        rightWall.position = CGPoint(x: 414.0, y: self.frame.midY)
        rightWall.size.width = 100
        rightWall.size.height = 736
        rightWall.color = UIColor.red
        rightWall.physicsBody = SKPhysicsBody(rectangleOf: leftWall.frame.size)
        rightWall.physicsBody?.restitution = 0.5
        
        rightWall.physicsBody?.friction = 0.5
        rightWall.physicsBody?.isDynamic = false
        rightWall.physicsBody?.categoryBitMask = physicsCategories.wallCategory
        self.addChild(rightWall)
        
        
        self.physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.0)
        self.physicsWorld.contactDelegate = self
    }
    
    override func didMove(to view: SKView) {
       let backgound = SKSpriteNode(imageNamed: "sky")
        backgound.zPosition = -1
        backgound.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        backgound.size.height = self.frame.height
        backgound.size.width = self.frame.width
        self.addChild(backgound)
        
        createGame()
        
        
        
        
        
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        //setting up player movement
        let firstBody:SKPhysicsBody
        let secondBody: SKPhysicsBody
        
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }else{
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if firstBody.categoryBitMask == physicsCategories.playerCategory  &&
            secondBody.categoryBitMask == physicsCategories.wallCategory{
            print("the ball hit the paddle, run sound action")
            run(jumpSoundAction)
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //called when a touch begins
        for touch in touches {
            createPlayer(touch: touch)
        }
    }
    
    func createPlayer(touch: UITouch){
        let location = touch.location(in: self)
        //Setting up player Physics and position and Collision detection
        let player = SKSpriteNode(imageNamed: "ball")
        player.name = physicsCategories.playerName
        player.position = location//CGPoint(x: self.frame.midX - 200, y: self.frame.midY)
        self.addChild(player)
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.height/2)
        player.physicsBody?.friction = 0.0
        player.physicsBody?.restitution = 1.0
        player.physicsBody?.linearDamping = 0.0
        player.physicsBody?.categoryBitMask = physicsCategories.playerCategory
        player.physicsBody?.contactTestBitMask = physicsCategories.wallCategory
        player.physicsBody?.applyImpulse(CGVector(dx: 10.0, dy:0.0))
        run(startSoundAction)
    }

    //function to create pipes
    func createPipes(){
        //setting up the scrore gate when the player passes a spike or pipe
        
        
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        //called before each frame is rendered
    }
}

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
    static let leftWallCategory: UInt32 = 0x1<<2
    static let rightWallCategory: UInt32 = 0x1<<4
    static let leftWallName:String = "leftWall"
    static let rightWallName:String = "rightWall"
    
    static let playerCategory: UInt32 = 0x1<<0
    static let playerName:String = "player"
    
    static let spikeCategory: UInt32 = 0x1<<1
    static let spikeName:String = "spike"
    
    static let scoreGateCategory: UInt32 = 0x1<<3
    static let scoreGateName: String = "scoreGate"
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    var musicPlaying: Bool = true
    var points = Int()
    var died = Bool()
    var restartButton = SKSpriteNode()
    var player = SKSpriteNode()
    var pipeLeft = SKSpriteNode()

    var pipeRight = SKSpriteNode()
    
    var leftWallTouch: Bool = false
    var rightWallTouch: Bool = false
    
    let scoreGate = SKSpriteNode()
    
    var moveRemove = SKAction()
    var spike = SKNode()
    var gameStarted = Bool()
    let scoreLabel = SKLabelNode()
    let startSoundAction: SKAction = SKAction.playSoundFileNamed("levelUp", waitForCompletion: true)
    let jumpSoundAction: SKAction = SKAction.playSoundFileNamed("jump", waitForCompletion: true)
    
    let pauseNode = SKSpriteNode()
    
    
    
    override func didMove(to view: SKView) {

        
        createGame()
        
    }
    
    
    
    //Determing what happens during collision
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
            secondBody.categoryBitMask == physicsCategories.leftWallCategory{
            print("the ball hit the left wall, run sound action")
            run(jumpSoundAction)
            player.removeAllActions()
            leftWallTouch = true
            rightWallTouch = false
            
        }
        
        if firstBody.categoryBitMask == physicsCategories.playerCategory  &&
            secondBody.categoryBitMask == physicsCategories.rightWallCategory{
            print("the ball hit the right wall, run sound action")
            run(jumpSoundAction)
            player.removeAllActions()
            rightWallTouch = true
            leftWallTouch = false
        }
        
        
        if firstBody.categoryBitMask == physicsCategories.scoreGateCategory &&
            secondBody.categoryBitMask == physicsCategories.playerCategory{
            points += 1
            scoreLabel.text = "\(points)"
        }
        if firstBody.categoryBitMask == physicsCategories.playerCategory &&
            secondBody.categoryBitMask == physicsCategories.spikeCategory ||
            firstBody.categoryBitMask == physicsCategories.spikeCategory &&
            secondBody.categoryBitMask == physicsCategories.playerCategory{
            enumerateChildNodes(withName: "pipe", using: {
                (node, error) in
                node.speed = 0;
                self.removeAllActions()
            })
            if died == false {
                die()
                SKTAudio.sharedInstance().pauseBackgroundMusic()
                self.scene?.removeAllActions()
            }
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //called when a touch begins
        
        let rightAction = SKAction.moveBy(x: 300, y: 0, duration: 0.1)
        player.run(rightAction)
        
        if leftWallTouch == true{
            let leftAction = SKAction.moveBy(x: 300, y: 0, duration: 0.1)
            player.run(leftAction)
            leftWallTouch = true
            rightWallTouch = false
        }
        
        if rightWallTouch == true{
            let rightAction = SKAction.moveBy(x: -300, y: 0, duration: 0.1)
            player.run(rightAction)
            rightWallTouch = true
            leftWallTouch = false
        }
        
        if gameStarted == false{
            restartButton.removeFromParent()
            let lower : UInt32 = 1
            let upper : UInt32 = 3
            let randomNum = arc4random_uniform(upper - lower) + lower
            print(randomNum)
            createPlayer()
            gameStarted = true
            player.physicsBody?.affectedByGravity = false;
            
            let pipeSpawn = SKAction.run({
                ()in
                self.createPipes()
            })
            
            let delay = SKAction.wait(forDuration: 2.0)
            let spawnDelay = SKAction.sequence([pipeSpawn, delay])
            let spawnForever = SKAction.repeatForever(spawnDelay)
            self.run(spawnForever)
            
            let distance = CGFloat(self.frame.width + spike.frame.width)
           
            let moveSpikes = SKAction.moveBy(x: -distance, y: 0, duration: TimeInterval(0.01 * distance))
            let removeSpikes = SKAction.removeFromParent()
            moveRemove = SKAction.sequence([moveSpikes, removeSpikes])
        }else{//you died and game can restart
            if died == true {
                self.scene?.removeAllActions()
                
            }else{
            }
        }
        
        for touch in touches {
            if restartButton.contains(touch.location(in: self)){
                restartScene()
            }
            
            if pauseNode.contains(touch.location(in: self)){
                if self.view?.isPaused == false {
                    pauseGame()
                }
                
                if self.view?.isPaused == true{
                    resumeGame()
                    self.view?.isPaused = false
                }
            }
            
            
            
            let location = touch.location(in: self)
            if died == true{
                if restartButton.contains(location){
                    restartScene()
                }
            }
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        //called before each frame is rendered
    }
    
    //function to restart the scene
    func restartScene(){
        self.removeAllActions()
        self.removeAllChildren()
        points = 0
        died = false
        gameStarted = false
        createGame()
    }
    
    //pause function
    func pauseGame(){
        let pauseAction = SKAction.run {
            self.view?.isPaused = true
            SKTAudio.sharedInstance().pauseBackgroundMusic()
        }
        self.run(pauseAction)
    }
    
    func resumeGame(){
        let resumeAction = SKAction.run{
            self.view?.isPaused = false
            SKTAudio.sharedInstance().resumeBackgroundMusic()
        }
        self.run(resumeAction)
    }
    
   
    
    //Function to start up the game
    func createGame() {
        //setting up music
        SKTAudio.sharedInstance().playBackgroundMusic("black-samurai.mp3")
        musicPlaying = true
        
        //setting up pause button
        pauseNode.zPosition = 5
        pauseNode.name = "pause"
        pauseNode.isUserInteractionEnabled = false
        pauseNode.position = CGPoint(x: self.frame.minX + 10, y: self.frame.minY + 10)
        pauseNode.size = CGSize(width: 50, height: 50)
        pauseNode.color = SKColor.black
        self.addChild(pauseNode)
      
        
        let backgound = SKSpriteNode(imageNamed: "sky")
        backgound.zPosition = -1
        backgound.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        backgound.size.height = self.frame.height
        backgound.size.width = self.frame.width
        self.addChild(backgound)
        
        self.physicsWorld.contactDelegate = self
        
        //boarder
        let boarder = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody = boarder
        
        //Setting up Score Label
        scoreLabel.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 + self.frame.height / 2.5)
        scoreLabel.text = "\(points)"
        scoreLabel.zPosition = 5
        scoreLabel.fontSize = 60
        self.addChild(scoreLabel)
        
        
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
        leftWall.physicsBody?.categoryBitMask = physicsCategories.leftWallCategory
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
        rightWall.physicsBody?.categoryBitMask = physicsCategories.rightWallCategory
        self.addChild(rightWall)
        
        
        self.physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.0)
        self.physicsWorld.contactDelegate = self
    }

    
    //Function to create the playable character
    func createPlayer(){
        died = false
        //Setting up player Physics and position and Collision detection
        player = SKSpriteNode(imageNamed: "ball")
        player.name = physicsCategories.playerName
        player.position = CGPoint(x: self.frame.midX, y: self.frame.midY - 30)
        self.addChild(player)
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.height/2)
        player.physicsBody?.friction = 0.0
        player.physicsBody?.restitution = 1.0
        player.physicsBody?.linearDamping = 0.0
        player.physicsBody?.categoryBitMask = physicsCategories.playerCategory
        player.physicsBody?.contactTestBitMask = physicsCategories.leftWallCategory
        player.physicsBody?.contactTestBitMask = physicsCategories.rightWallCategory
        run(startSoundAction)
    }

    //function to create pipes
    func createPipes(){
        //setting up the scrore gate when the player passes a spike or pipe
        
        //setting up the score gate
        scoreGate.name = "scoreGate"
        scoreGate.size = CGSize(width: 500, height: 1)
        scoreGate.physicsBody = SKPhysicsBody(rectangleOf: scoreGate.size)
        scoreGate.physicsBody?.categoryBitMask = physicsCategories.scoreGateCategory
        scoreGate.physicsBody?.contactTestBitMask = physicsCategories.playerCategory
        scoreGate.physicsBody?.affectedByGravity = false
        scoreGate.physicsBody?.isDynamic = false
        scoreGate.position = CGPoint(x: self.frame.midX, y: self.frame.height + 20)
        
        
        
        //Setting up the left pipe
        let leftPipe = SKSpriteNode()
        leftPipe.size.height = 100
        leftPipe.size.width = 300
        leftPipe.name = physicsCategories.spikeName
        leftPipe.color = SKColor.yellow
        leftPipe.physicsBody = SKPhysicsBody(rectangleOf: leftPipe.size)
        leftPipe.physicsBody?.categoryBitMask = physicsCategories.spikeCategory
        leftPipe.physicsBody?.collisionBitMask = physicsCategories.playerCategory
        leftPipe.physicsBody?.contactTestBitMask = physicsCategories.playerCategory;
        leftPipe.physicsBody?.affectedByGravity = false
        leftPipe.physicsBody?.isDynamic = false
        leftPipe.position = CGPoint(x: self.frame.minX, y: self.frame.height + 20)
        self.addChild(leftPipe)
        
        //setting up the right pipes
        let rightPipe = SKSpriteNode()
        rightPipe.name = physicsCategories.spikeName
        rightPipe.size.height = 100
        rightPipe.size.width = 300
        rightPipe.color = SKColor.cyan
        rightPipe.physicsBody = SKPhysicsBody(rectangleOf: leftPipe.size)
        rightPipe.physicsBody?.categoryBitMask = physicsCategories.spikeCategory
        rightPipe.physicsBody?.collisionBitMask = physicsCategories.playerCategory
        rightPipe.physicsBody?.contactTestBitMask = physicsCategories.playerCategory;
        rightPipe.position = CGPoint(x: self.frame.maxX, y: self.frame.height + 20)
        rightPipe.physicsBody?.affectedByGravity = true
        rightPipe.physicsBody?.isDynamic = false
        self.addChild(rightPipe)
        
        
        let minDuration: CGFloat = 2.0
        let maxDuration: CGFloat = 8.0
        let rangeDuration: CGFloat = maxDuration - minDuration
        let actualDuration = (CGFloat(arc4random()).truncatingRemainder(dividingBy: rangeDuration)) + minDuration
        let actualDuration2 = (CGFloat(arc4random()).truncatingRemainder(dividingBy: rangeDuration)) + minDuration
        
        let done : SKAction = SKAction.removeFromParent()
        let leftactionMove = SKAction.move(to: CGPoint(x: leftPipe.position.x, y: -200), duration: TimeInterval(actualDuration))
        let rightactionMove = SKAction.move(to: CGPoint(x: rightPipe.position.x, y: -200), duration: TimeInterval(actualDuration2))
        let scoregateLeft = SKAction.move(to: CGPoint(x: scoreGate.position.x, y:-200), duration: TimeInterval(actualDuration))
        let scoregateRight = SKAction.move(to: CGPoint(x: scoreGate.position.x, y:-200), duration: TimeInterval(actualDuration2))
        

        scoreGate.run(SKAction.sequence([scoregateLeft, scoregateRight, done]))
        rightPipe.run(SKAction.sequence([rightactionMove,done]))
        leftPipe.run(SKAction.sequence([leftactionMove,done]))

        
        //setting up random nuber fucntion
    
        
    }
    
    
    //function called when player dies
    func die(){
        //function called when the player touches a spike
        died = false
        player.removeAllActions()
        createRestartButton()
    }
    
    //function to restart the game and play again
    func createRestartButton() {
        restartButton = SKSpriteNode(color: SKColor.black, size: CGSize(width: 200, height: 100))
        restartButton.position = CGPoint(x: self.frame.midX, y: self.frame.midY - 20)
        restartButton.zPosition = 6
        self.addChild(restartButton)
        restartButton.run(SKAction.scale(to: 1.0, duration: 0.3))
    }
   

}

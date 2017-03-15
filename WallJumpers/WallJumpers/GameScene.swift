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
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    //MARK: Game Variables and Nodes
    
    //Game Bools
    var musicPlaying: Bool = true
    var gameStarted = Bool()
    var leftWallTouch: Bool = false
    var rightWallTouch: Bool = false
    var died = Bool()

    //Game Nodes
    var restartButton = SKSpriteNode()
    var player = SKSpriteNode()
    let scoreGate = SKSpriteNode()
    var spike = SKNode()
    let scoreLabel = SKLabelNode()
    let pauseNode = SKSpriteNode(imageNamed: "pause.png")
    
    //Other Variables
    var points : Int = 0

    //Game Actions
    var moveRemove = SKAction()
    var dropRemove = SKAction()
    let startSoundAction: SKAction = SKAction.playSoundFileNamed("levelUp", waitForCompletion: true)
    let jumpSoundAction: SKAction = SKAction.playSoundFileNamed("jump", waitForCompletion: true)
    let coinAnimatieAction : SKAction = SKAction.animate(with: [SKTexture(imageNamed: "Gold_1"),
                                                                SKTexture(imageNamed: "Gold_2"),
                                                                SKTexture(imageNamed: "Gold_3"),
                                                                SKTexture(imageNamed: "Gold_4"),
                                                                SKTexture(imageNamed: "Gold_5"),
                                                                SKTexture(imageNamed: "Gold_6"),
                                                                SKTexture(imageNamed: "Gold_7"),
                                                                SKTexture(imageNamed: "Gold_8"),
                                                                SKTexture(imageNamed: "Gold_9"),
                                                                SKTexture(imageNamed: "Gold_10"),], timePerFrame: 0.5)
    
    
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //MARK: SPRITE KIT METHODS
    
    override func didMove(to view: SKView) {
        createGame()
//        
//        let swipeRight: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("swipedRight:"))
//        swipeRight.direction = .right
//        view.addGestureRecognizer(swipeRight)
//        
//        let swipeLeft: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("swipedLeft:"))
    }
    
    
    //SETTING WHAT HAPPENS DURING COLLISION
    func didBegin(_ contact: SKPhysicsContact) {
        //SETTING UP PHYSICS COLLISIONS
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
    
    //SETTING UP TOUCHES
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //called when a touch begins
        print(frame.size.width)
        
        if leftWallTouch == false && rightWallTouch == false {
            var firstTouch = Int()
            //Random number 1 or 2
            let lower : UInt32 = 1
            let upper : UInt32 = 3
            let randomNum = arc4random_uniform(upper - lower) + lower
            print(randomNum)
            
            if randomNum == 1 {
                firstTouch = 50
            }else if randomNum == 2 {
                firstTouch = 364
            }
            
            let rightAction = SKAction.moveBy(x: CGFloat(firstTouch), y: 0, duration: 0.4)
            player.run(rightAction)
        }

        
        if leftWallTouch == true{
           // let leftAction = SKAction.moveBy(x: 100, y: 0, duration: 0.4)
            let leftMove = SKAction.moveTo(x: 50, duration: 0.4)
            player.run(leftMove)
        }
        
        if rightWallTouch == true{
           // let rightAction = SKAction.moveBy(x: -100, y: 0, duration: 0.8)
            
            let rightMove = SKAction.moveTo(x: 364, duration: 0.4)

            player.run(rightMove)
        }
        
        if gameStarted == false{
            restartButton.removeFromParent()
        
            
            
            createPlayer()
            gameStarted = true
            player.physicsBody?.affectedByGravity = false;
            
            let pipeSpawn = SKAction.run({
                ()in
                self.createPipes()
            })
            
            let coinSpawn = SKAction.run({
                ()in
                self.spawnCoins()
            })
            
            let delay = SKAction.wait(forDuration: 2.0)
            let spawnDelay = SKAction.sequence([pipeSpawn, coinSpawn,delay])
            let spawnForever = SKAction.repeatForever(spawnDelay)
            self.run(spawnForever)
            
            let distance = CGFloat(self.frame.width + spike.frame.width)
           
            let moveSpikes = SKAction.moveBy(x: -distance, y: 0, duration: TimeInterval(0.01 * distance))
            let removeSpikes = SKAction.removeFromParent()
            moveRemove = SKAction.sequence([moveSpikes, removeSpikes])
        }else{
            //you died and game can restart
            if died == true {
                self.scene?.removeAllActions()
                
            }else{
            }
        }
        
        //
        //SETTING TOUCHES FOR SPECIFIC LOCATIONS
        for touch in touches {
            if restartButton.contains(touch.location(in: self)){
                restartScene()}
            
            if pauseNode.contains(touch.location(in: self)){
                if self.view?.isPaused == false {
                    pauseGame()}
                
                if self.view?.isPaused == true {
                    resumeGame()
                    self.view?.isPaused = false}
            }
            
            let location = touch.location(in: self)
            
            if died == true{
                if restartButton.contains(location){
                    restartScene()
                }}
            
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    //UPDATE
    override func update(_ currentTime: TimeInterval) {
        //called before each frame is rendered
        
        print("Touching the left wall \(leftWallTouch)")
        print("Touching the right wall \(rightWallTouch)")
        
//        
//        if leftPipe.position.y < player.position.y || rightPipe.position.y < player.position.y {
//            points += 1
//            scoreLabel.text = "\(points)"
//        }
//        
//        
//        if leftPipe.position.y < self.frame.minY || rightPipe.position.y < self.frame.minY  {
//          leftPipe.removeFromParent()
//            rightPipe.removeFromParent()
//        }
        
        //Making sure points are current
        scoreLabel.text = "\(points)"
        
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    //MARK: GAME FUNCTIONS
    
    //
    //SWIPEING FUNCTIONS 
    func swipedRight(sender: UISwipeGestureRecognizer){
        print("swiped right")
    }
    func swipedLeft(sender: UISwipeGestureRecognizer){
        print("swiped left")
    }
    

    //
    //CREATE THE GAME FUNCTION
    func createGame() {
        //SETTING UP MUSIC FOR GAME
        SKTAudio.sharedInstance().playBackgroundMusic("black-samurai.mp3")
        musicPlaying = true
        
        //SETTING UP THE PAUSE BUTTON
        pauseNode.zPosition = 5
        pauseNode.name = "pause"
        pauseNode.isUserInteractionEnabled = false
        pauseNode.position = CGPoint(x: self.frame.maxX - 30, y: self.frame.maxY - 30)
        pauseNode.size = CGSize(width: 50, height: 50)
        self.addChild(pauseNode)
      
        //SETTING UP BACKGROUND
        let backgound = SKSpriteNode(imageNamed: "sky")
        backgound.zPosition = -1
        backgound.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        backgound.size.height = self.frame.height
        backgound.size.width = self.frame.width
        self.addChild(backgound)
        
        self.physicsWorld.contactDelegate = self
        
        //SETTING BOARDER AND PHYSICS
        let boarder = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody = boarder
        
        //SETTING THE SCORE LABEL NODE FOR THE PLAYERS CURRNT SCORE
        scoreLabel.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 + self.frame.height / 2.5)
        scoreLabel.text = "\(points)"
        scoreLabel.zPosition = 100
        scoreLabel.fontSize = 60
        self.addChild(scoreLabel)
        
        
        //SETTING THE LEFT WALL
        let leftWall = SKSpriteNode(imageNamed: "brick")
        leftWall.name = physicsCategories.leftWallName
        leftWall.position = CGPoint(x: 0.0, y: self.frame.midY)
        leftWall.zPosition = 1
        leftWall.size.width = 100.0
        leftWall.size.height = 736
        leftWall.color = UIColor.blue
        leftWall.physicsBody = SKPhysicsBody(rectangleOf: leftWall.frame.size)
        leftWall.physicsBody?.restitution = 0.0
        leftWall.physicsBody?.friction = 0.0
        leftWall.physicsBody?.isDynamic = false
        leftWall.physicsBody?.categoryBitMask = physicsCategories.leftWallCategory
        self.addChild(leftWall)
    
        
        //CREATING THE RIGHT WALL
        let rightWall = SKSpriteNode(imageNamed: "brick")
        rightWall.name = physicsCategories.rightWallName
        rightWall.position = CGPoint(x: 414.0, y: self.frame.midY)
        rightWall.zPosition = 1
        rightWall.size.width = 100
        rightWall.size.height = 736
        rightWall.color = UIColor.red
        rightWall.physicsBody = SKPhysicsBody(rectangleOf: leftWall.frame.size)
        rightWall.physicsBody?.restitution = 0.5
        
        rightWall.physicsBody?.friction = 0.5
        rightWall.physicsBody?.isDynamic = false
        rightWall.physicsBody?.categoryBitMask = physicsCategories.rightWallCategory
        self.addChild(rightWall)
        
        print("left wall x position is " + "\(leftWall.position.x)" + " , right wall x position is " + "\(rightWall.position.x)" )
        print("the right side of left wall? "  +  "\(leftWall.frame.maxX)")
        print("the left side of right wall? "  +  "\(rightWall.frame.minX)")

        self.physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.0)
        self.physicsWorld.contactDelegate = self
    }

    //
    //CREATE THE PLAYER FUNCTION
    func createPlayer(){
        died = false
        //Setting up player Physics and position and Collision detection
        player = SKSpriteNode(imageNamed: "ball")
        player.name = physicsCategories.playerName
        player.position = CGPoint(x: self.frame.midX, y: self.frame.midY - 200)
        player.zPosition = 2
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
    
    //
    //CREATE FALLING COINS FUNCTION
    func spawnCoins(){
        let coin = SKSpriteNode()
        coin.run(coinAnimatieAction)
        coin.physicsBody?.collisionBitMask = physicsCategories.playerCategory
        coin.physicsBody?.contactTestBitMask = physicsCategories.playerCategory;
        coin.physicsBody?.affectedByGravity = false
        coin.physicsBody?.isDynamic = false
        coin.position = CGPoint(x: self.frame.midX, y: self.frame.height + 20)
        self.addChild(coin)
        
        let minDuration: CGFloat = 2.0
        let maxDuration: CGFloat = 8.0
        let rangeDuration: CGFloat = maxDuration - minDuration
        let actualDuration = (CGFloat(arc4random()).truncatingRemainder(dividingBy: rangeDuration)) + minDuration
        let done : SKAction = SKAction.removeFromParent()
        let coinDrop = SKAction.move(to: CGPoint(x: coin.position.x, y: -10), duration: TimeInterval(actualDuration))
        
        coin.run(SKAction.sequence([coinDrop,done]))
    }

    //
    //CREATE FALLING PIPES
    func createPipes(){
        //SETUP OF LEFT PIPE
        let leftPipe = SKSpriteNode()
        leftPipe.size.height = 100
        leftPipe.size.width = 300
        leftPipe.name = physicsCategories.spikeName
        leftPipe.zPosition = 0
        leftPipe.color = SKColor.yellow
        leftPipe.physicsBody = SKPhysicsBody(rectangleOf: leftPipe.size)
        leftPipe.physicsBody?.categoryBitMask = physicsCategories.spikeCategory
        leftPipe.physicsBody?.collisionBitMask = physicsCategories.playerCategory
        leftPipe.physicsBody?.contactTestBitMask = physicsCategories.playerCategory;
        leftPipe.physicsBody?.affectedByGravity = false
        leftPipe.physicsBody?.isDynamic = false
        leftPipe.position = CGPoint(x: self.frame.minX, y: self.frame.height + 20)
        self.addChild(leftPipe)
        
        //SET UP OF RIGHT PIPE
        let rightPipe = SKSpriteNode()
        rightPipe.zPosition = 0
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
        
        //AWARDING POINTS TO PLAYER IF PIPES ARE BLOW THE PLAYER
        if leftPipe.position.x < self.player.position.x {
            points += 1
        }
        if  rightPipe.position.x < self.player.position.x{
            points += 1
        }
        
        
        //DETERIMING HOW FAST THE PIPES WILL DROP
        let minDuration: CGFloat = 2.0
        let maxDuration: CGFloat = 8.0
        let rangeDuration: CGFloat = maxDuration - minDuration
        let actualDuration = (CGFloat(arc4random()).truncatingRemainder(dividingBy: rangeDuration)) + minDuration
        let actualDuration2 = (CGFloat(arc4random()).truncatingRemainder(dividingBy: rangeDuration)) + minDuration
        
        //SETTING THE ACTIONS ON THE PIPE NODES
        let done : SKAction = SKAction.removeFromParent()
        let leftactionMove = SKAction.move(to: CGPoint(x: leftPipe.position.x, y: -200), duration: TimeInterval(actualDuration))
        let rightactionMove = SKAction.move(to: CGPoint(x: rightPipe.position.x, y: -200), duration: TimeInterval(actualDuration2))
        rightPipe.run(SKAction.sequence([rightactionMove,done]))
        leftPipe.run(SKAction.sequence([leftactionMove,done]))
    }
    
    
    //FUNCTION TO RESTART THE SCENE
    func restartScene(){
        self.removeAllActions()
        self.removeAllChildren()
        points = 0
        died = false
        gameStarted = false
        createGame()
    }
    
    //RESTART THE GAME FUNCTION
    func createRestartButton() {
        restartButton = SKSpriteNode(color: SKColor.black, size: CGSize(width: 200, height: 100))
        restartButton.position = CGPoint(x: self.frame.midX, y: self.frame.midY - 20)
        restartButton.zPosition = 100
        self.addChild(restartButton)
        restartButton.run(SKAction.scale(to: 1.0, duration: 0.3))
    }
    
    //PAUSEING THE GAME FUNCTION
    func pauseGame(){
        let pauseAction = SKAction.run {
            self.view?.isPaused = true
            SKTAudio.sharedInstance().pauseBackgroundMusic()
        }
        self.run(pauseAction)
    }
    
    //RESUMEING THE GAME FUNSTION
    func resumeGame(){
        let resumeAction = SKAction.run{
            self.view?.isPaused = false
            SKTAudio.sharedInstance().resumeBackgroundMusic()
        }
        self.run(resumeAction)
    }
    
    //PLAYER DIED FUNCTION
    func die(){
        //function called when the player touches a spike
        died = false
        player.removeAllActions()
        createRestartButton()
    }
    
}

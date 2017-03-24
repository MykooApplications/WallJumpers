//
//  GameScene.swift
//  WallJumpers
//
//  Created by Roshan Mykoo on 3/2/17.
//  Copyright © 2017 Roshan Mykoo. All rights reserved.
//

import SpriteKit
import GameplayKit
import GameKit

struct physicsCategories {
    static let leftWallCategory: UInt32 = 0x1<<2
    static let rightWallCategory: UInt32 = 0x1<<4
    static let leftWallName:String = "leftWall"
    static let rightWallName:String = "rightWall"
    
    static let playerCategory: UInt32 = 0x1<<0
    static let playerName:String = "player"
    
    static let spikeCategory: UInt32 = 0x1<<1
    static let rightSpikeName:String = "right_spike"
    static let leftSpikeName:String = "left_spike"
    
    static let scoreGateCategory: UInt32 = 0x1<<3
    static let scoreGateName: String = "scoreGate"
    
    static let coinCategory : UInt32 = 0x1<<5
    static let coinName : String = "coin"
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    ////////////////////////////////////////////////////////////////////////////////////////////
    //MARK: Game Variables and Nodes

    //GAMECENTER
    var gamecenterEnabled = Bool()
    var gamecenterDefaultLeaderBoard = String()
    let LEADERBOARD_ID = "grp.score.walljumper"
    var score: Int = 0
    var playerDeaths: Int = 0
    var playerCoins: Int = 0
    var playerSwipes: Int = 0

    
    //Game Bools
    var musicPlaying: Bool = true
    var gameStarted = Bool()
    var leftWallTouch: Bool = false
    var rightWallTouch: Bool = false
    var died = Bool()

    //Game Nodes
    var restartLabel = SKLabelNode(text: "Restart")
    var restartButton = SKSpriteNode()

    var player = SKSpriteNode()
    let scoreGate = SKSpriteNode()
    var spike = SKNode()
    let scoreLabel = SKLabelNode()
    let pauseNode = SKSpriteNode(imageNamed: "pause.png")
    
    
    var swipeTo = SKLabelNode(text: "Swipe To")
    var movePlayer = SKLabelNode(text: "Move Player!")
    var dodgeSpikes = SKLabelNode(text: "Dodge The Spikes!")
    
 

    //Other Variables
    var points : Int = 0

    //Game Actions
    var moveRemove = SKAction()
    var dropRemove = SKAction()
    let startSoundAction: SKAction = SKAction.playSoundFileNamed("levelUp", waitForCompletion: true)
    let jumpSoundAction: SKAction = SKAction.playSoundFileNamed("jump", waitForCompletion: true)

    
    ////////////////////////////////////////////////////////////////////////////////////////////
    //MARK: SPRITE KIT METHODS
    
    //SWIPEING METHODS TO BE RECONISED IN DID MOVE TO
    func swipedRight(sender:UISwipeGestureRecognizer){
        //print("swipe right")
        player.texture = SKTexture(imageNamed: "runright")
        let rightAction = SKAction.moveTo(x: 364, duration: 0.3)
        player.run(rightAction)
        playerSwipes += 1
    }
    func swipedLeft(sender:UISwipeGestureRecognizer){
        //print("swipe left")
        player.texture = SKTexture(imageNamed: "runleft")
        let leftAction = SKAction.moveTo(x: 50, duration: 0.3)
        player.run(leftAction)
        playerSwipes += 1
    }
    
    
    override func didMove(to view: SKView) {
        playerDeaths = 0
        createGame()
        showInstructions()
        
        let swipeRight: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.swipedRight))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
        
        let swipeLeft: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.swipedLeft))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)
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
            player.texture = SKTexture(imageNamed: "leftWallJump")
            //print("the ball hit the left wall, run sound action")
            run(jumpSoundAction)
            player.removeAllActions()
            leftWallTouch = true
            rightWallTouch = false
            //print("Left collide")
            
        }
        
        if firstBody.categoryBitMask == physicsCategories.playerCategory  &&
            secondBody.categoryBitMask == physicsCategories.rightWallCategory{
            player.texture = SKTexture(imageNamed: "rightWallJump")
            //print("the ball hit the right wall, run sound action")
            run(jumpSoundAction)
            player.removeAllActions()
            rightWallTouch = true
            leftWallTouch = false
            //print("right collide")
        }
        
        
        if firstBody.categoryBitMask == physicsCategories.playerCategory &&
            secondBody.categoryBitMask == physicsCategories.coinCategory ||
            firstBody.categoryBitMask == physicsCategories.coinCategory &&
            secondBody.categoryBitMask == physicsCategories.playerCategory{
            print("player got a coin")
            playerCoins += 1
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
        if gameStarted == false{
            removeInstructions()
            restartButton.removeFromParent()
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
            let moveCoins = SKAction.moveBy(x: -distance, y: 0, duration: TimeInterval(0.01*distance))
            let removeSpikes = SKAction.removeFromParent()
            moveRemove = SKAction.sequence([moveSpikes,moveCoins, removeSpikes])
            
            
        }else{
            //you died and game can restart
            if died == true {
                self.scene?.removeAllActions()
            }
        }
        
        //
        //SETTING TOUCHES FOR SPECIFIC LOCATIONS
        for touch in touches {
//            if restartButton.contains(touch.location(in: self)){
//                restartScene()
//            }
            
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
        checkAchivements()
        //Making sure points are current
        scoreLabel.text = "\(points)"
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////
    //MARK: GAME FUNCTIONS
    //GAME INSTRUSTIONS
    func showInstructions(){
        swipeTo.position = CGPoint(x: self.frame.midX, y: self.frame.midY + 50)
        movePlayer.position = CGPoint(x: self.frame.midX, y: swipeTo.position.y - 50)
        dodgeSpikes.position = CGPoint(x: self.frame.midX, y: movePlayer.position.y - 50)
        swipeTo.fontSize = 50
        swipeTo.color = UIColor.black
        movePlayer.fontSize = 50
        movePlayer.color = UIColor.black
        dodgeSpikes.fontSize = 30
        dodgeSpikes.color = UIColor.black
        
        self.addChild(swipeTo)
        self.addChild(movePlayer)
        self.addChild(dodgeSpikes)
    }
    func removeInstructions(){
        self.removeChildren(in: [swipeTo,movePlayer, dodgeSpikes])
    }
    

    //
    //CREATE THE GAME FUNCTION
    func createGame() {
        let light = SKLightNode()
        light.position = CGPoint(x: self.frame.midX, y: self.frame.maxX + 10)
        light.falloff = 1
        light.lightColor = UIColor.white
        self.addChild(light)
        createPlayer()
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
        
        //Setting up Score Label
        scoreLabel.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 + self.frame.height / 2.5)
        scoreLabel.text = "\(points)"
        scoreLabel.zPosition = 5
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
        rightWall.physicsBody?.restitution = 0
        rightWall.physicsBody?.friction = 0
        rightWall.physicsBody?.isDynamic = false
        rightWall.physicsBody?.categoryBitMask = physicsCategories.rightWallCategory
        self.addChild(rightWall)
        
        //print("left wall x position is " + "\(leftWall.position.x)" + " , right wall x position is " + "\(rightWall.position.x)" )
       // print("the right side of left wall? "  +  "\(leftWall.frame.maxX)")
        //print("the left side of right wall? "  +  "\(rightWall.frame.minX)")

        self.physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.0)
        self.physicsWorld.contactDelegate = self
    }

    //
    //CREATE THE PLAYER FUNCTION
    func createPlayer(){
        died = false
        //Setting up player Physics and position and Collision detection
        player = SKSpriteNode(imageNamed: "runright")
        player.xScale = 0.1
        player.yScale = 0.1
        player.name = physicsCategories.playerName
        player.position = CGPoint(x: self.frame.midX, y: self.frame.midY - 200)
        player.zPosition = 2
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.height/2)
        player.physicsBody?.friction = 0.0
        player.physicsBody?.restitution = 1.0
        player.physicsBody?.linearDamping = 0.0
        player.physicsBody?.categoryBitMask = physicsCategories.playerCategory
        player.physicsBody?.collisionBitMask = 0
        player.physicsBody?.contactTestBitMask = physicsCategories.leftWallCategory
        player.physicsBody?.contactTestBitMask = physicsCategories.rightWallCategory
        player.physicsBody?.contactTestBitMask = physicsCategories.coinCategory
        self.addChild(player)
        run(startSoundAction)
    }
    
    //
    //CREATE FALLING COINS FUNCTION
    func spawnCoins(){
        let coin = SKSpriteNode(imageNamed: "Gold_1")
        let coinAnimatieAction : SKAction = SKAction.animate(with: [SKTexture(imageNamed: "Gold_1"),
                                                                    SKTexture(imageNamed: "Gold_2"),
                                                                    SKTexture(imageNamed: "Gold_3"),
                                                                    SKTexture(imageNamed: "Gold_4"),
                                                                    SKTexture(imageNamed: "Gold_5"),
                                                                    SKTexture(imageNamed: "Gold_6"),
                                                                    SKTexture(imageNamed: "Gold_7"),
                                                                    SKTexture(imageNamed: "Gold_8"),
                                                                    SKTexture(imageNamed: "Gold_9"),
                                                                    SKTexture(imageNamed: "Gold_10")], timePerFrame: 0.25)
        
        coin.color = SKColor.red
        coin.size = CGSize(width: 75, height: 75)
        coin.run(coinAnimatieAction)
        coin.name = physicsCategories.coinName
        
        coin.physicsBody = SKPhysicsBody(circleOfRadius: 75.0)
        coin.physicsBody?.categoryBitMask = physicsCategories.coinCategory;
        coin.physicsBody?.collisionBitMask = 0
        coin.physicsBody?.contactTestBitMask = physicsCategories.playerCategory;
        coin.physicsBody?.affectedByGravity = false
        coin.physicsBody?.isDynamic = false
//        coin.xScale = 0.05
//        coin.yScale = 0.05
        coin.position = CGPoint(x: self.frame.midX, y: self.frame.maxY + 20)
        self.addChild(coin)
        let minDuration: CGFloat = 2.0
        let maxDuration: CGFloat = 4.0
        let rangeDuration: CGFloat = maxDuration - minDuration
        let actualDuration = (CGFloat(arc4random()).truncatingRemainder(dividingBy: rangeDuration)) + minDuration
        let done : SKAction = SKAction.removeFromParent()
        let coinDrop = SKAction.move(to: CGPoint(x: coin.position.x, y: -10), duration: TimeInterval(actualDuration))
        coin.run(SKAction.sequence([coinDrop ,done]))
    }

    //
    //CREATE FALLING PIPES
    func createPipes(){
        let rightPipe = SKSpriteNode()
        let leftPipe = SKSpriteNode()
        
        //AWARDING POINTS TO PLAYER IF PIPES ARE BLOW THE PLAYER
        if leftPipe.position.y < 207 {
            points += 1
            //print("left point")
        }
        if  rightPipe.position.y < 207{
            points += 1
            //print("right point")
        }
        

        scoreLabel.text = "\(points)"
        //SETUP OF LEFT PIPE
        leftPipe.size.height = 100
        leftPipe.size.width = 300
        leftPipe.name = physicsCategories.leftSpikeName
        leftPipe.zPosition = 0
        leftPipe.color = SKColor.yellow
        leftPipe.physicsBody = SKPhysicsBody(rectangleOf: leftPipe.size)
        leftPipe.physicsBody?.categoryBitMask = physicsCategories.spikeCategory
        leftPipe.physicsBody?.collisionBitMask = physicsCategories.playerCategory
        leftPipe.physicsBody?.contactTestBitMask = physicsCategories.playerCategory
        leftPipe.physicsBody?.affectedByGravity = false
        leftPipe.physicsBody?.isDynamic = false
        leftPipe.position = CGPoint(x: self.frame.minX, y: self.frame.height + 20)
        
        
        //SET UP OF RIGHT PIPE
        rightPipe.zPosition = 0
        rightPipe.name = physicsCategories.rightSpikeName
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
        self.addChild(leftPipe)
        self.addChild(rightPipe)
        
   
        
        //DETERIMING HOW FAST THE PIPES WILL DROP
        let minDuration: CGFloat = 2.0
        let maxDuration: CGFloat = 6.0
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
        playerCoins = 0
        died = false
        gameStarted = false
        createGame()
        self.childNode(withName: "restart")?.removeFromParent()
    }
    
    //RESTART THE GAME FUNCTION
    func createRestartButton() {
        restartLabel.color = SKColor.white
        restartLabel.fontSize = 50
        restartLabel.zPosition = 3
        restartButton = SKSpriteNode(color: SKColor.black, size: CGSize(width: 200, height: 70))
        restartButton.name = String("restart")
        restartButton.position = CGPoint(x: self.frame.midX, y: self.frame.midY - 20)
        restartButton.zPosition = 100
        //restartLabel.position = CGPoint(x: self.restartButton.frame.midX, y: self.restartButton.frame.midY)
        restartButton.addChild(restartLabel)
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
        died = true
        playerDeaths += 1
        player.removeAllActions()
        createRestartButton()
        submitScore(score: points)
    }
    
    
    //MARK: GAME CENTER
    func authenticateLocalPlayer(){
        let localPlayer: GKLocalPlayer = GKLocalPlayer.localPlayer()
        localPlayer.authenticateHandler = {(ViewController, error)-> Void in
            if((ViewController) != nil){
                
            }else if(localPlayer.isAuthenticated){
                self.gamecenterEnabled = true
                
                localPlayer.loadDefaultLeaderboardIdentifier(completionHandler: { (leaderboadIdentifer, error) in
                    if error != nil {
                        
                    }else{
                        self.gamecenterDefaultLeaderBoard = leaderboadIdentifer!
                    }
                })
            }else {
                self.gamecenterEnabled = false
                
            }
        }
    }
    
    func submitScore(score: Int){
        
        let playerScore = score
        
        let bestScoreInt = GKScore(leaderboardIdentifier: LEADERBOARD_ID)
        bestScoreInt.value = Int64(playerScore)
        GKScore.report([bestScoreInt]){ (error) in
            if error != nil{
                //print("score error ====  \(error?.localizedDescription as Any)")

            }else{
               // print ("the player's score after death\(bestScoreInt)")
            }
            
        
        }
    }
    
    func checkAchivements(){
        if points >= 5{
            let achivement = GKAchievement(identifier: "grp.5pointsScore")
            if achivement.isCompleted == true{
                achivement.showsCompletionBanner = false
            }else{
                achivement.percentComplete = 100.0
                achivement.showsCompletionBanner = true
                GKAchievement.report([achivement], withCompletionHandler: nil)
                //print(achivement.isCompleted)
            }
        }
        
        if points >= 10{
            let achivement = GKAchievement(identifier: "grp.10pointsScore")
            if achivement.isCompleted == true{
                achivement.showsCompletionBanner = false
            }else{
                achivement.percentComplete = 100.0
                achivement.showsCompletionBanner = true
                GKAchievement.report([achivement], withCompletionHandler: nil)
            }
        }
        
        if points >= 25{
            let achivement = GKAchievement(identifier: "grp.25pointScore")
            if achivement.isCompleted == true{
                achivement.showsCompletionBanner = false
                
            }else{
                achivement.percentComplete = 100.0
                achivement.showsCompletionBanner = true
                GKAchievement.report([achivement], withCompletionHandler: nil)
            }
        }
        
        if points >= 50{
            let achivement = GKAchievement(identifier: "grp.50scorePoints")
            if achivement.isCompleted == true{
                achivement.showsCompletionBanner = false
                
            }else{
                achivement.percentComplete = 100.0
                achivement.showsCompletionBanner = true
                GKAchievement.report([achivement], withCompletionHandler: nil)
            }
        }
        
        if playerDeaths >= 5{
            let achivement = GKAchievement(identifier: "grp.5die")
            if achivement.isCompleted == true{
                achivement.showsCompletionBanner = false
                
            }else if achivement.isCompleted == false{
                achivement.percentComplete = 100.0
                achivement.showsCompletionBanner = true
                GKAchievement.report([achivement], withCompletionHandler: nil)
            }
        }
        
        if playerDeaths >= 10{
            let achivement = GKAchievement(identifier: "grp.10die")
            if achivement.isCompleted == true{
                achivement.showsCompletionBanner = false
                
            }else if achivement.isCompleted == false{
                achivement.percentComplete = 100.0
                achivement.showsCompletionBanner = true
                GKAchievement.report([achivement], withCompletionHandler: nil)
            }
        }
        
        if playerSwipes >= 100{
            let achivement = GKAchievement(identifier: "grp.100swpie")
            if achivement.isCompleted == false{
                achivement.percentComplete = 100.0
                achivement.showsCompletionBanner = true
                GKAchievement.report([achivement], withCompletionHandler: nil)
            }
        }
        
        if playerSwipes >= 500{
            let achivement = GKAchievement(identifier: "grp.500swipes")
            if achivement.isCompleted == false{
                achivement.percentComplete = 100.0
                achivement.showsCompletionBanner = true
                GKAchievement.report([achivement], withCompletionHandler: nil)
            }
        }
        
        if playerCoins >= 5{
            let achivement = GKAchievement(identifier: "grp.5coinCollect")
            if achivement.isCompleted == false{
                achivement.percentComplete = 100.0
                achivement.showsCompletionBanner = true
                GKAchievement.report([achivement], withCompletionHandler: nil)
            }
        }
        
        if playerCoins >= 50{
            let achivement = GKAchievement(identifier: "grp.50coinCollect")
            if achivement.isCompleted == false{
                achivement.percentComplete = 100.0
                achivement.showsCompletionBanner = true
                GKAchievement.report([achivement], withCompletionHandler: nil)
            }
        }
    }

    
    

}

//
//  MenuScene.swift
//  WallJumpers
//
//  Created by Roshan Mykoo on 3/13/17.
//  Copyright © 2017 Roshan Mykoo. All rights reserved.
//

import Foundation
import SpriteKit


class MenuScene: SKScene {
    
    var playGameLabel = SKLabelNode()
    var leaderBoardLabel = SKLabelNode()
    var achivementsLabel = SKLabelNode()
    var creditsLabel = SKLabelNode()
    
    
    override func didMove(to view: SKView) {
        createMenu()
        createAppInfo()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if playGameLabel.contains(touch.location(in: self)){
                startGame()
            }
            if leaderBoardLabel.contains(touch.location(in: self)){
                
            }
            if achivementsLabel.contains(touch.location(in: self)) {
                
            }
            if creditsLabel.contains(touch.location(in: self)){
                showCredits()
            }
        }
    }

    func startGame(){
        let gameScene = GameScene(size: (view?.bounds.size)!)
        let transition = SKTransition.fade(withDuration: 0.15)
        view?.presentScene(gameScene, transition: transition)
    }
    
    func showCredits(){
        let creditsScene = CreditsScene(size: (view?.bounds.size)!)
        let transition = SKTransition.fade(withDuration: 0.15)
        view?.presentScene(creditsScene, transition: transition)
    }
    
    func createAppInfo(){
        let appIcon = SKSpriteNode(imageNamed: "iconSplash")
        appIcon.position = CGPoint(x: self.frame.midX, y: self.frame.maxY - 150)
        appIcon.size = CGSize(width: 200, height: 200)
        self.addChild(appIcon)
        
        let appName = SKLabelNode(text: "Wall Jumpers")
        appName.position = CGPoint(x: self.frame.midX, y: appIcon.position.y - 200)
        appName.fontSize = 60
        appName.fontName = "Helvetica-Bold"
        self.addChild(appName)
        
    }
    
    func createMenu(){
        //Background
        let backgound = SKSpriteNode(imageNamed: "brick")
        backgound.zPosition = -1
        backgound.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        backgound.size.height = self.frame.height
        backgound.size.width = self.frame.width
        self.addChild(backgound)
        
        //Setting up Play Game Button
        playGameLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY - 100)
        playGameLabel.text = "Play Game"
        playGameLabel.fontName = "Helvetica-Bold"
        playGameLabel.zPosition = 5
        playGameLabel.fontSize = 50
        playGameLabel.fontColor = SKColor.green
        self.addChild(playGameLabel)
        print(playGameLabel.position.y)
        
        //Setting up Leaderboards Button
        leaderBoardLabel.position = CGPoint(x: self.frame.midX, y: playGameLabel.position.y - 70)
        leaderBoardLabel.text = "Leaderboards"
        leaderBoardLabel.fontName = "Helvetica-Bold"
        leaderBoardLabel.zPosition = 5
        leaderBoardLabel.fontSize = 50
        self.addChild(leaderBoardLabel)
        
        //Setting up Achivements Button
        achivementsLabel.position = CGPoint(x: self.frame.midX, y: leaderBoardLabel.position.y - 60)
        achivementsLabel.text = "Achivements"
        achivementsLabel.fontName = "Helvetica-Bold"
        achivementsLabel.zPosition = 5
        achivementsLabel.fontSize = 50
        self.addChild(achivementsLabel)
        
        //Setting up Credits Button
        creditsLabel.position = CGPoint(x: self.frame.midX, y: achivementsLabel.position.y - 60)
        creditsLabel.text = "Credits"
        creditsLabel.zPosition = 5
        creditsLabel.fontName = "Helvetica-Bold"
        creditsLabel.fontSize = 50
        self.addChild(creditsLabel)
        
    }
    
    
    
}

//
//  CreditsScene.swift
//  WallJumpers
//
//  Created by Roshan Mykoo on 3/14/17.
//  Copyright © 2017 Roshan Mykoo. All rights reserved.
//

import Foundation
import SpriteKit

class CreditsScene : SKScene {
   
    var backLabel = SKLabelNode()
    
    
    override func didMove(to view: SKView) {
        createScene()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if backLabel.contains(touch.location(in: self)){
                returnMenu()
            }
          
          
        }
    }
    
    func createScene(){
        let backgound = SKSpriteNode(imageNamed: "brick")
        backgound.zPosition = -1
        backgound.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        backgound.size.height = self.frame.height
        backgound.size.width = self.frame.width
        self.addChild(backgound)
        
        
        let madeBy = SKLabelNode()
        madeBy.text = "Made By"
        madeBy.position = CGPoint(x: self.frame.midX, y: 600)
        madeBy.fontSize = 50
        madeBy.fontName = "Helvetica-Bold"
        self.addChild(madeBy)
        
        let roshanMykoo = SKLabelNode()
        roshanMykoo.text = "Roshan Mykoo"
        roshanMykoo.position = CGPoint(x: self.frame.midX, y: madeBy.position.y - 60)
        roshanMykoo.fontSize = 50
        roshanMykoo.fontColor = SKColor.black
        roshanMykoo.fontName = "Helvetica-Bold"
        self.addChild(roshanMykoo)
        
        let fullSail = SKLabelNode()
        fullSail.text = "At Full Sail University"
        fullSail.fontSize = 50
        fullSail.fontName = "Helvetica-Bold"
        fullSail.position = CGPoint(x: self.frame.midX, y: roshanMykoo.position.y - 60)
        self.addChild(fullSail)
        
        
        backLabel.text = "Back"
        backLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY - 60)
        backLabel.fontSize = 50
        backLabel.color = SKColor.red
        self.addChild(backLabel)
    }
    
    func returnMenu(){
        let menuScene = MenuScene(size: (view?.bounds.size)!)
        let transition = SKTransition.fade(withDuration: 0.15)
        view?.presentScene(menuScene, transition: transition)
    }
    
}

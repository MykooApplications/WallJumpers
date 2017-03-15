//
//  WallParallaxScrolling.swift
//  WallJumpers
//
//  Created by Roshan Mykoo on 3/15/17.
//  Copyright © 2017 Roshan Mykoo. All rights reserved.
//

import Foundation
import SpriteKit

class WallParallaxScrolling: SKSpriteNode {
    var backgrounds:[SKSpriteNode] = []
    var cloneBackground:[SKSpriteNode] = []
    var speeds:[CGFloat] = []
    
    
    override init(texture: SKTexture?, color: SKColor, size: CGSize){
        super.init(texture: texture, color: color, size: size)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder has not been implemented")
    }
    
    
    func setUpBackgrounds(_ backgrounds:[String], size: CGSize, fastestSpeed: CGFloat, speedDecreases: CGFloat){
        self.zPosition = -1
        self.position = CGPoint(x: size.width/2, y: size.height/2)
        
        let zPos = 1.0/Double(backgrounds.count)
        
        var bgNumber = 0.0
        
        var tempBackgounds: [SKSpriteNode] = []
        var tempClonedBackgrounds:[SKSpriteNode] = []
        var tempSpeeds:[CGFloat] = []
        var currentSpeed: CGFloat = fastestSpeed
        
        for currentBackground in backgrounds{
            if let node:SKSpriteNode = SKSpriteNode(imageNamed: currentBackground){
                node.zPosition = self.zPosition - CGFloat(zPos + (zPos * bgNumber))
                node.position = CGPoint(x: 0, y: 0)
                node.size = size
                
                let cloneNode :SKSpriteNode = SKSpriteNode(imageNamed: currentBackground)
                cloneNode.zPosition = self.zPosition - CGFloat(zPos + (zPos * bgNumber))
                cloneNode.position = CGPoint(x: -node.size.width, y: 0)
                cloneNode.size = size
                
                tempBackgounds.append(node)
                tempClonedBackgrounds.append(cloneNode)
                tempSpeeds.append(currentSpeed)
                
                currentSpeed = CGFloat(currentSpeed - speedDecreases)
                if currentSpeed < 0.0 {
                    currentSpeed = 0.5
                }
                
                self.addChild(node)
                self.addChild(cloneNode)
                bgNumber += 1
            }
            
            
            if bgNumber > 0 {
                
                self.backgrounds = tempBackgounds
                self.cloneBackground = tempClonedBackgrounds
                self.speeds = tempSpeeds
            }
        }
    }
    
    
    func update() {
        for (index, currentBackground) in backgrounds.enumerated(){
            let speed = self.speeds[index]
            let clonedBackground = self.cloneBackground[index]
            
            var newBGx = currentBackground.position.x
            var newCloneBGx = clonedBackground.position.x
            
            newBGx -= speed
            newCloneBGx -= speed
            
            if newBGx <= -currentBackground.size.width {
                newBGx = newCloneBGx + clonedBackground.size.width - 0.05
            }
            
            if newCloneBGx <= -clonedBackground.size.width {
                newCloneBGx = newBGx + currentBackground.size.width - 0.05
            }
            
            currentBackground.position = CGPoint(x: newBGx, y: currentBackground.position.y)
            clonedBackground.position = CGPoint(x: newCloneBGx, y: clonedBackground.position.y)
        }
    }

    
}

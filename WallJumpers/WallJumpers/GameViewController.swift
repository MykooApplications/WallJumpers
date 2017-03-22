//
//  GameViewController.swift
//  WallJumpers
//
//  Created by Roshan Mykoo on 3/2/17.
//  Copyright © 2017 Roshan Mykoo. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import GameKit

class GameViewController: UIViewController, GKGameCenterControllerDelegate {
    //GameCenter
    var score: Int = 0
    var gamecenterEnabled = Bool()
    var gamecenterDefaultLeaderBoard = String()
    
    var localPlayer = GKLocalPlayer.localPlayer()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        localPlayer.authenticateHandler = {(GameViewController, error) -> Void in
            if ((GameViewController) != nil){
                self.present(GameViewController!, animated: true, completion: nil)
            }else{
                print(GKLocalPlayer.localPlayer().isAuthenticated)
            }
            
        }
        // Load 'GameScene.sks' as a GKScene. This provides gameplay related content
        // including entities and graphs.
        if let scene = GKScene(fileNamed: "MenuScene") {
            
            // Get the SKScene from the loaded GKScene
            if let sceneNode = scene.rootNode as! MenuScene? {
                
                // Copy gameplay related content over to the scene
   
                
                // Set the scale mode to scale to fit the window
                sceneNode.scaleMode = .aspectFill
                
                // Present the scene
                if let view = self.view as! SKView? {
                    view.presentScene(sceneNode)
                    
                    view.ignoresSiblingOrder = true
                    
                    view.showsFPS = true
                    view.showsNodeCount = true
                }
            }
        }
    }
    //GameCenter Functions
    //authenticate local player
    func authenticateLocalPlayer() {
        let localPlayer: GKLocalPlayer = GKLocalPlayer.localPlayer()
        localPlayer.authenticateHandler = {(GameViewController, error) -> Void in
            if ((GameViewController) != nil) {
                self.present(GameViewController!, animated: true, completion:nil)

            }else if (GKLocalPlayer.localPlayer().isAuthenticated){
                self.gamecenterEnabled = true
              
            }else {
                self.gamecenterEnabled = false
                print("local player could not be authenticated")
            }
            
            
        }
    }



    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    func showLeaderBoard(){
        let gameCenterViewController: GKGameCenterViewController = GKGameCenterViewController()
      //  gameCenterViewController.delegate = self
        gameCenterViewController.viewState = GKGameCenterViewControllerState.leaderboards
        gameCenterViewController.leaderboardIdentifier = "grp.score.walljumper"
        self.present(gameCenterViewController, animated: true, completion: nil)
        self.navigationController?.pushViewController(gameCenterViewController, animated: true)
    }
    
    func gameCenterViewControllerDidFinish(_ gcViewController: GKGameCenterViewController){
        self.dismiss(animated: true, completion: nil)
    }
}

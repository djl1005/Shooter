//
//  GameViewController.swift
//  shoter
//
//  Created by student on 9/22/16.
//  Copyright © 2016 djl1005. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    //MARK: -ivars-
    var gameScene: GameScene?
    var skView:SKView!
    let showDebugData = true
    let screneSize = CGSize(width: 1920, height: 1080)
    let scaleMode = SKSceneScaleMode.aspectFill

    //MARK" -init-
    override func viewDidLoad() {
        super.viewDidLoad()
        
        skView = self.view as! SKView
        loadHomeScene()
        
        //debugstuff
        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true
        
    }
    
    //MARK: -scene managment-
    func loadHomeScene(){
        let scene = HomeScene(size:screneSize, scaleMode:scaleMode, sceneManager:self)
        let revel = SKTransition.crossFade(withDuration: 1)
        skView.presentScene(scene, transition: revel)
    }
    
    func loadGameScene(levelNum:Int, lives: Int, eHealth: Int){
        gameScene = GameScene(size: screneSize, scaleMode: scaleMode, levelNum: levelNum, lives:lives, eHealth:eHealth, sceneManager: self)
        let reveal = SKTransition.doorsOpenHorizontal(withDuration: 1)
        skView.presentScene(gameScene!, transition: reveal)
    }
    
    func loadLevelFinishScene(results:LevelResults){
        gameScene = nil
        let scene = LevelFinishScene(size: screneSize, scaleMode: scaleMode, results: results, sceneManager: self)
        let re = SKTransition.crossFade(withDuration: 1)
        skView.presentScene(scene, transition: re)
    }
    
    func loadGameOverScene(results:LevelResults){
        gameScene = nil
        let scene = GameOverScene(size: screneSize, scaleMode: scaleMode, results: results, sceneManager: self)
        let re = SKTransition.crossFade(withDuration: 1)
        skView.presentScene(scene, transition: re)
    }

    override var shouldAutorotate: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}

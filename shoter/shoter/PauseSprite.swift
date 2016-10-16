//
//  PauseSprite.swift
//  shoter
//
//  Created by student on 10/16/16.
//  Copyright © 2016 djl1005. All rights reserved.
//

import Foundation
import SpriteKit

class PauseSprite {
    
    var node:SKShapeNode
    let pausedAlpha:CGFloat = 0.5
    
    init(){
        let rect = CGRect(x: 0, y: 0, width: 1920, height: 1080)
        node = SKShapeNode(rect: rect)
        node.fillColor = SKColor.gray
        node.alpha = pausedAlpha
        node.zPosition = GameData.drawOrder.hud
        
        let PauseText:SKLabelNode = SKLabelNode(text: "Paused")
        PauseText.fontSize = 25
        PauseText.position.x = rect.midX
        PauseText.position.y = rect.midY
        PauseText.fontName = "Futura"
        
        node.addChild(PauseText)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func attach (scene: SKScene){
        scene.addChild(node)
    }
    
    func remove (){
        node.removeFromParent()
    }
    
    func paused(){
        node.alpha = pausedAlpha
    }
    
    func unPaused (){
        node.alpha = 0
    }
    
}

//
//  AlienSprite.swift
//  shoter
//
//  Created by student on 9/26/16.
//  Copyright © 2016 djl1005. All rights reserved.
//

import Foundation
import SpriteKit

class AlienSprite: SKSpriteNode {
    
    var fwd:CGPoint = CGPoint(x: 0.0, y: 1.0)
    var velocity:CGPoint = CGPoint.zero
    var delta:CGFloat = 300.0
    var hit:Bool = false
    var health:Int
    
    
    init(){
        health = 3
        super.init(texture: SKTexture(image: #imageLiteral(resourceName: "Alien")),  color: GameData.player.playerColor, size: GameData.player.playerSize);
        self.zRotation = CGFloat(M_PI * 0.5)
        self.zPosition = GameData.drawOrder.enemy
        
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.wait(forDuration:  TimeInterval(CGFloat.random(min: 2, max: 3.5))),
                SKAction.run(fire),
                ])
        ))
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("ds")
    }
    
    func fire(){
        Bullet(isPlayer: false, spawnPoint: self.position, scene: self.parent as! SKScene)
    }
    
    func update(dt:CGFloat) {
        velocity = fwd * delta
        position = position + velocity * dt
    }
    
    func reflectX(){
        fwd.x *= CGFloat(-1.0)
    }
    
    func reflectY(){
        fwd.y *= CGFloat(-1.0)
    }
    
}


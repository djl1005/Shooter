//
//  PlayerSprite.swift
//  shoter
//
//  Created by student on 9/25/16.
//  Copyright © 2016 djl1005. All rights reserved.
//

import Foundation
import SpriteKit

class PlayerSprite: SKSpriteNode {
    
    var isFiring = false
    var lifes = 5
    
    
    init(){
        super.init(texture: SKTexture(image:#imageLiteral(resourceName: "Spaceship")),  color: GameData.player.playerColor, size: GameData.player.playerSize);
        self.position = CGPoint(x: 200, y: 540)
        self.zRotation = CGFloat(-M_PI * 0.5)
        
        self.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width:30,height:50))
        self.physicsBody?.isDynamic = true
        self.physicsBody?.categoryBitMask = GameData.PhysicsCategory.PLayer
        self.physicsBody?.contactTestBitMask = GameData.PhysicsCategory.EnemyBullet
        self.physicsBody?.collisionBitMask = GameData.PhysicsCategory.None
        self.physicsBody?.usesPreciseCollisionDetection = true
        self.physicsBody?.affectedByGravity = false
        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("ds")
    }
    
}

//
//  BombShipSprite.swift
//  shoter
//
//  Created by Sung Choi on 10/2/16.
//  Copyright © 2016 swc1098. All rights reserved.
//

import Foundation
import SpriteKit

// create bombship object
class BombShipSprite: SKSpriteNode {
    
    var isFiring = false
    var health = 10
    
    
    init(){
        super.init(texture: SKTexture(imageNamed:"BombShip.png"),  color: GameData.player.playerColor, size: GameData.player.playerSize);
        self.position = CGPoint(x: 200, y: 100)
        self.zRotation = CGFloat(-M_PI * 0.5)
        
        self.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width:30,height:50))
        
        self.physicsBody?.isDynamic = true
        self.physicsBody?.categoryBitMask = GameData.PhysicsCategory.BombShip
        self.physicsBody?.contactTestBitMask = GameData.PhysicsCategory.EnemyBullet
        self.physicsBody?.collisionBitMask = GameData.PhysicsCategory.None
        self.physicsBody?.usesPreciseCollisionDetection = true
        self.physicsBody?.affectedByGravity = false
        
        // same as player
        self.zPosition = GameData.drawOrder.player
        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("ds")
    }
    
}

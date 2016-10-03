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
    
    var canLaunch = true
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
    
    func approachEnemy(){
        // create a general lifetime of approach
        //let bombApproachSpeed = CGFloat(10.0)
        //let raidSpeed = CGFloat(15.0)
        let bombApproachSpeed = CGFloat(4.0)
        let raidSpeed = CGFloat(4.0)
        
        
        // move to the end of screen in 3 seconds, maintaining y position
        let actionApproach = SKAction.move(to: CGPoint(x: self.position.x + 1600, y: self.position.y), duration: TimeInterval(bombApproachSpeed))
        
        // rotate by 90 degrees
        let actionRotate = SKAction.rotate(byAngle: CGFloat(M_PI_2), duration: 3.0)
        
        let actionFlyUp = SKAction.move(to: CGPoint(x: self.position.x + 1600, y: self.position.y + 900), duration: TimeInterval(raidSpeed))
        
        let actionFlyBack = SKAction.move(to: CGPoint(x: self.position.x, y: self.position.y + 900), duration: TimeInterval(bombApproachSpeed))
        
        let actionDone = SKAction.removeFromParent()
        
        run(SKAction.sequence([
            actionApproach,
            actionRotate,
            actionFlyUp,
            actionRotate,
            actionFlyBack,
            actionDone
            ])
        )
    }
}

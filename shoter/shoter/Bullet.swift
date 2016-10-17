//
//  Bullet.swift
//  shoter
//
//  Created by student on 9/26/16.
//  Copyright © 2016 djl1005. All rights reserved.
//

import Foundation
import SpriteKit

class Bullet{
    
    let sprite: SKSpriteNode
    //var shotSpeed:Double = 0.2
    
    
    // MARK: This is bloated, but fires the bullet in a direction. Just declaring the class will serve to act. 
    init(isPlayer:Bool, spawnPoint:CGPoint, scene: SKScene) {
        //is player bullet
        if(isPlayer){
            sprite = SKSpriteNode(imageNamed:"bullet.png")
            setUp(spawnPoint: spawnPoint)
            sprite.zRotation = CGFloat(-M_PI * 0.5)
            
            sprite.zPosition = GameData.drawOrder.playerBullet
            
            sprite.physicsBody?.categoryBitMask = GameData.PhysicsCategory.PlayerBullet
            sprite.physicsBody?.contactTestBitMask = GameData.PhysicsCategory.Enemy
            
            scene.addChild(sprite)
            
            // how long until bullet reaches destination?
            let bulletLifeTime = CGFloat(3.0)
            
            
            // move to the end of screen in 3 seconds, maintaining y position
            let actionMove = SKAction.move(to: CGPoint(x: scene.size.width - sprite.size.width/2, y: spawnPoint.y), duration: TimeInterval(bulletLifeTime))
            
            let actionMoveDone = SKAction.removeFromParent()
            
            //let wait = SKAction.wait(forDuration: shotSpeed)
            
            // run actions above
            sprite.run(SKAction.sequence([actionMove, actionMoveDone]))

            
        } else {
            sprite = SKSpriteNode(imageNamed:"bullet.png") // TODO: change to enemy bullet
            setUp(spawnPoint: spawnPoint)
            
            sprite.zRotation = CGFloat(M_PI * 0.5)
            
            sprite.zPosition = GameData.drawOrder.enemyBullet
            
            sprite.physicsBody?.categoryBitMask = GameData.PhysicsCategory.EnemyBullet
            sprite.physicsBody?.contactTestBitMask = GameData.PhysicsCategory.Player
            
            sprite.size = CGSize(width: sprite.size.width/2, height: sprite.size.height/2)
            
            sprite.color = .green
            sprite.colorBlendFactor = 0.75
            
            scene.addChild(sprite)
            
            // how long until bullet reaches destination?
            let bulletLifeTime = CGFloat(4.0)
            
            
            // move to the end of screen in 3 seconds, maintaining y position
            let actionMove = SKAction.move(to: CGPoint(x: 0, y: spawnPoint.y), duration: TimeInterval(bulletLifeTime))
            
            let actionMoveDone = SKAction.removeFromParent()
            
            // run actions above
            sprite.run(SKAction.sequence([actionMove, actionMoveDone]))

        }
        
    }
    
    // Universal setuUp for bullets
    private func setUp(spawnPoint:CGPoint){
        sprite.position = spawnPoint
        
        sprite.size = CGSize(width: sprite.size.width/2, height: sprite.size.height/2)
        
        sprite.physicsBody = SKPhysicsBody(rectangleOf: sprite.size)
        sprite.physicsBody?.isDynamic = true

        sprite.physicsBody?.collisionBitMask = GameData.PhysicsCategory.None
        sprite.physicsBody?.affectedByGravity = false
    }
    
}

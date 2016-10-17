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
    var health = 20
    // var firedShot: Int = 0
    var bullet = SKSpriteNode(imageNamed:"bombShot.png")
    
    var expEmitter = SKEmitterNode(fileNamed: "Damage")
    
    var isLaunched = false;
    
    init(){
        super.init(texture: SKTexture(imageNamed:"bombShip.png"),  color: GameData.player.playerColor, size: GameData.player.playerSize);
        self.position = CGPoint(x: 0, y: 100)
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
    
    //MARK: Handles the raid
    func approachEnemy(){
        // create a general lifetime of approach
        //let bombApproachSpeed = CGFloat(10.0)
        //let raidSpeed = CGFloat(15.0)
        let bombApproachSpeed = CGFloat(4.0)
        let raidSpeed = CGFloat(15.0)
        
        GameData.player.isPlayerBombing = true
        
        // move to the end of screen in 3 seconds, maintaining y position
        let actionApproach = SKAction.move(to: CGPoint(x: self.position.x + 1525, y: self.position.y), duration: TimeInterval(bombApproachSpeed))
        
        // rotate by 90 degrees
        let actionRotate = SKAction.rotate(byAngle: CGFloat(M_PI_2), duration: 2.0)
        
        let actionFlyUp = SKAction.move(to: CGPoint(x: self.position.x + 1525, y: self.position.y + 900), duration: TimeInterval(raidSpeed))
        
        let actionFlyBack = SKAction.move(to: CGPoint(x: self.position.x - 75, y: self.position.y + 900), duration: TimeInterval(bombApproachSpeed))
        
        let actionDone = SKAction.sequence([
            SKAction.removeFromParent(),
            resetLaunch()
            
        ])
        
        // group two actions together
        var fireAndMove = Array<SKAction>()
        
        fireAndMove.append(actionFlyUp)
        fireAndMove.append(spawnBullet())
        //fireAndMove.append(checkStop())
        let FAM = SKAction.group(fireAndMove)
        
        run(SKAction.sequence([
            actionApproach,
            actionRotate,
            FAM,
            //fireStop(),
            actionRotate,
            actionFlyBack,
            actionDone
            ]), withKey:"Hi"
        )
        
    }
    //func fire(){
        //bullet = SKSpriteNode(imageNamed:"bullet.png") //TODO: MAKE IT DIFFERENT FROM PLAYER'S
    //}
    
    // MARK: The bread and potatoes of the bombing run
    func fireAction() -> SKAction{
        return SKAction.run{
            
            self.bullet = SKSpriteNode(imageNamed:"bombShot.png")
            
            self.bullet.position = CGPoint(x:self.position.x,y:self.position.y)
            self.bullet.zRotation = CGFloat(-M_PI * 0.5)
            self.bullet.size = CGSize(width: self.bullet.size.width * 1.5, height: self.bullet.size.height * 1.5)
            self.bullet.zPosition = GameData.drawOrder.bombBullet
            //self.bullet.color = .cyan
            //self.bullet.colorBlendFactor = 0.66
            
            // TODO: Make Bullet visible on scene
            self.scene!.addChild(self.bullet)
            
            // how long until bullet reaches destination?
            let bulletLifeTime = CGFloat(2.0)
            
            
            // move to the end of screen in 3 seconds, maintaining y position
            let fire = SKAction.move(to: CGPoint(x: 1900, y: self.position.y), duration: TimeInterval(bulletLifeTime))
            
            let damage = SKAction.run {
                let s = self.scene as! GameScene
                s.fHealth -= 1;
            }
            let explode = self.explosion()
            
            let done = SKAction.removeFromParent()
            
            let sequence = SKAction.sequence([fire, damage, explode ,done])
            //print ("FIRING")
            self.bullet.run(sequence, withKey: "Firing")
            
        }
    }
    //MARK: continues the bullet fire
    func spawnBullet() -> SKAction{
        let seq = SKAction.sequence([fireAction(), SKAction.wait(forDuration: 1.2)])
        return SKAction.repeat(seq, count: 12)
        
    }
    
    //MARK: Just resets ship launch position so that it can go again.
    func resetLaunch() -> SKAction{
        return SKAction.run{
            self.isLaunched = false
            self.canLaunch = true
            GameData.player.isPlayerBombing = false
            self.position = CGPoint(x: 0, y: 100)
            self.zRotation = CGFloat(-M_PI * 0.5)
        }
    }
    
    //MARK: create explosive effect!
    func explosion() -> SKAction{
        return SKAction.run{
            self.expEmitter = SKEmitterNode(fileNamed: "Damage")
            self.expEmitter?.position = CGPoint(x:1900, y: self.bullet.position.y - 100)
            self.expEmitter?.zPosition = 5
            self.scene!.addChild(self.expEmitter!)
            
            let waitForExp = SKAction.wait(forDuration: 1.4)
            let remove = SKAction.removeFromParent()
            
            let dura = SKAction.sequence([waitForExp, remove])
            
            self.expEmitter!.run(dura)
        }
    }
    // CRASHES!
    //func spawnBullet() -> SKAction{
    //   return SKAction.run{
    //        self.run(SKAction.repeatForever(
    //            SKAction.sequence([
    //                self.fireAction(),
    //               SKAction.wait(forDuration: 1.0)
    //                ])
    //       ))
    //    }
    //}
    
    //func fireStop() -> SKAction{
    //   return SKAction.run{
    //        self.removeAction(forKey: "Firing")
    //        self.bullet.removeAction(forKey:"Firing")
    //    }
    //}
}

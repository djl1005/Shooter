//
//  GameScene.swift
//  shoter
//
//  Created by student on 9/22/16.
//  Copyright © 2016 djl1005. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate  {
    var levelNum:Int
    

    let sceneManager:GameViewController
    
    var tapCount = 0
    
    var playbleRect = CGRect.zero
    var enemyRect = CGRect.zero //area where enemies can spawn
    var totalSprites = 0
    
    let lifesLabel = SKLabelNode(fontNamed: "Futura")
    
    let player = PlayerSprite()
    
    var lastUpdateTime: TimeInterval = 0
    var dt: TimeInterval = 0
    var spritesMoving = false
    
    //MARK: - Init -
    
    init(size: CGSize, scaleMode:SKSceneScaleMode, levelNum:Int, totalScore:Int, sceneManager:GameViewController) {
        self.levelNum = levelNum
        self.sceneManager = sceneManager
        super.init(size: size)
        self.scaleMode = scaleMode
    }
    
    required init?(coder aDecoder: NSCoder){
        fatalError("not implmented")
    }
    
    override func didMove(to view: SKView) {
        setupUI()
        makeEnemies(howMany: 10)
        unpauseSprites()
        
        // spawns bullets infinitely
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run(spawnBullet),
                SKAction.wait(forDuration: 0.2),
                ])
        ))
    }
    
    deinit {
        //TODO: set
    }
    
    private func setupUI(){
        playbleRect = getPlayableRectPhoneLandscape(size: size)
        enemyRect = CGRect(x: playbleRect.width/2, y: 0, width: playbleRect.width/2, height: playbleRect.height)
        let fontSize = GameData.hud.fontSize
        let fontColor = GameData.hud.fontColorWhite
        let marginH = GameData.hud.marginH
        let marginV = GameData.hud.marginV
        
        backgroundColor = GameData.hud.backgroundColor
        
        lifesLabel.fontColor = fontColor
        lifesLabel.fontSize = fontSize
        lifesLabel.position = CGPoint(x: marginH, y: playbleRect.maxY - marginV)
        lifesLabel.verticalAlignmentMode = .top
        lifesLabel.horizontalAlignmentMode = .left
        
        lifesLabel.text = "Lifes: \(player.lifes)"
        addChild(lifesLabel)
        
        

        addChild(player)
        
        // checks to see if two objects collide
        physicsWorld.contactDelegate = self
    }
    
    //MARK: -events-
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
            
            //player movment
        
            if let touch = touches.first {
                 player.position.y = touch.location(in: self).y
                 player.isFiring = true
            }
            
            return
        
        
//        if levelNum < GameData.maxLevel{
//            totalScore += levelScore
//            let results = LevelResults(levelNum: levelNum, levelScore: levelScore, totalScore: totalScore, msg: "you finished level \(levelNum)")
//            sceneManager.loadLevelFinishScene(results: results)
//        } else {
//            totalScore += levelScore
//            let results = LevelResults(levelNum: levelNum, levelScore: levelScore, totalScore: totalScore, msg: "you finished level \(levelNum)")
//           sceneManager.loadGameOverScene(results: results)
//        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            player.position.y = touch.location(in: self).y
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            player.position.y = touch.location(in: self).y
            player.isFiring = false
        }
    }
    
    func makeEnemies(howMany:Int){
        
        var s:AlienSprite
        
        for _ in 0...howMany-1{
            s = AlienSprite()
            s.name = "Enemy"
            
            s.position = randomCGPointInRect(enemyRect, margin: 50)
            
            addChild(s)
            
            // check physics body of sprite (Hopefully will collide with bullet)
            s.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width:30,height:50))
            s.physicsBody?.isDynamic = true
            s.physicsBody?.categoryBitMask = GameData.PhysicsCategory.Enemy
            s.physicsBody?.contactTestBitMask = GameData.PhysicsCategory.PLayerBullet
            s.physicsBody?.collisionBitMask = GameData.PhysicsCategory.None
            s.physicsBody?.usesPreciseCollisionDetection = true
            s.physicsBody?.affectedByGravity = false
        }
    }
    
    // spawns bullets into game
    func spawnBullet(){
        // only spawn if player is firing
        if player.isFiring{
             Bullet(isPlayer: true, spawnPoint: player.position, secene: self)
        }
        
    }
    
    // create a handler to check for bullet collision
    func playerBulletCollided(enemy:AlienSprite,bullet:SKSpriteNode){
        print("BOOM")
        enemy.health -= 1
        if enemy.health <= 0{
        enemy.removeFromParent()
        }
        bullet.removeFromParent()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        // 1
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA // player || playerBullet
            secondBody = contact.bodyB // enemy || EnemyBullet
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        // 2
        if ((firstBody.categoryBitMask & GameData.PhysicsCategory.PLayerBullet != 0) &&
            (secondBody.categoryBitMask & GameData.PhysicsCategory.Enemy != 0) &&
            firstBody.node != nil && secondBody.node != nil) {
            playerBulletCollided(enemy: secondBody.node as! AlienSprite, bullet: firstBody.node as! SKSpriteNode)
        }
        
    }

    //MARK: -Game Loop-
    
    func unpauseSprites(){
        let unpsuseAction = SKAction.sequence([
            SKAction.wait(forDuration: 2),
            SKAction.run({self.spritesMoving = true})
        ])
        run(unpsuseAction)
    }
    
    func calculateDeltaTime(currentTime: TimeInterval){
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        
        lastUpdateTime = currentTime;
    }
    
    func moveSprites(dt: CGFloat){
        if spritesMoving{
            enumerateChildNodes(withName: "Enemy", using: {node, stop in
                let s = node as! AlienSprite
                let halfWidth = s.frame.width/2
                let halfHeight = s.frame.height/2
                
                s.update(dt: dt)
                
                if(s.position.x <= halfWidth || s.position.x >= self.size.width - halfWidth){
                    s.reflectX()
                    s.update(dt: dt)
                }
                
                if(s.position.y <= self.playbleRect.minY + halfHeight || s.position.y >= self.playbleRect.maxY - halfHeight) {
                    s.reflectY()
                    s.update(dt: dt)
                }
            })
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        calculateDeltaTime(currentTime: currentTime)
        moveSprites(dt: CGFloat(dt))
    }
    
    }

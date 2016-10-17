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
    var enemySpawnRate = 2
    let sceneManager:GameViewController
    var playableRect = CGRect.zero
    var enemyRect = CGRect.zero //area where enemies can spawn
    var numEnemies = 0;
    
    let pauseNode = PauseSprite()
    var isFirstUnpause: Bool = false
    var gameIsPaused:Bool {
        didSet {
            gameIsPaused ? pause() : unPause()
        }
    }
    var pauseButton: SKNode! = nil
    
    func pause() {
        run(
        SKAction.sequence([SKAction.run {
            self.pauseNode.paused()
            }, SKAction.run {
                self.pauseNode.paused()
                self.physicsWorld.speed = 0.0
                self.spritesMoving = false
                self.view?.isPaused = true
            }])
        )

    }
    
    func unPause() {
        pauseNode.unPaused()
        self.view?.isPaused = false
        physicsWorld.speed = 1.0
        spritesMoving = true
        lastUpdateTime = 0
        
        
        if(!isFirstUnpause){
            run(SKAction.repeatForever(
                SKAction.sequence([
                    SKAction.run(spawnBullet),
                    SKAction.wait(forDuration: 0.3),
                    ])
            ))
            
            run(SKAction.repeatForever(
                SKAction.sequence([
                    SKAction.run(makeEnemies),
                    SKAction.wait(forDuration: 3),
                    ])
            ))
            
            isFirstUnpause = true
        }
    }
    
    
    let livesLabel = SKLabelNode(fontNamed: "Futura")
    let fHealthLabel = SKLabelNode(fontNamed: "Futura")
    
    let bombLaunchLabel = SKLabelNode(fontNamed: "Futura")
    
    let spaceEmitter = SKEmitterNode(fileNamed: "Space")!
    
    var tapY : CGFloat?
    
    
    let player = PlayerSprite()
    let bombShip = BombShipSprite()
    
    var lastUpdateTime: TimeInterval = 0
    var dt: TimeInterval = 0
    var spritesMoving = false
    
    var fHealth: Int{
        didSet{
            fHealthLabel.text = "Enemy Health: \(fHealth)"
            
            if(fHealth <= 0){
                let results = LevelResults(levelNum: levelNum, levelScore: 0, lives: player.lives, msg: "you finished level \(levelNum)")
                    sceneManager.loadLevelFinishScene(results: results)
            }
        }
    }
    
    //MARK: - Init -
    
    init(size: CGSize, scaleMode:SKSceneScaleMode, levelNum:Int, lives:Int, frHealth:Int, sceneManager:GameViewController) {
        self.levelNum = levelNum
        self.sceneManager = sceneManager
        self.fHealth = frHealth
        player.lives = lives
        gameIsPaused = true
        
        super.init(size: size)
        self.scaleMode = scaleMode
        

    }
    
    required init?(coder aDecoder: NSCoder){
        fatalError("not implemented")
    }
    
    override func didMove(to view: SKView) {
        setupUI()     
    }

    deinit {
        //TODO: set
    }
    
    private func setupUI(){
        playableRect = getPlayableRectPhoneLandscape(size: size)
        enemyRect = CGRect(x: playableRect.width/2, y: 0, width: playableRect.width/2, height: playableRect.height)
        let fontSize = GameData.hud.fontSize
        let fontColor = GameData.hud.fontColorWhite
        let marginH = GameData.hud.marginH
        let marginV = GameData.hud.marginV
        
        //backgroundColor = UIColor.black
        
        
        let background = SKSpriteNode(texture: SKTexture(image:#imageLiteral(resourceName: "gameBg")), size: size)
        
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        
        background.zPosition = GameData.drawOrder.bg
        
        addChild(background)
        
        // let's try adding visual representation
        let freighter = SKSpriteNode(texture:SKTexture(imageNamed:"freighter.png"), size: CGSize(width: 850, height: 1650))
        
        freighter.position = CGPoint(x: 2000, y: size.height/2)
        
        freighter.zPosition = GameData.drawOrder.enemy
        
        addChild(freighter)
        
        livesLabel.fontColor = fontColor
        livesLabel.fontSize = fontSize
        livesLabel.position = CGPoint(x: marginH, y: playableRect.maxY - marginV)
        livesLabel.verticalAlignmentMode = .top
        livesLabel.horizontalAlignmentMode = .left
        
        livesLabel.text = "Lives: \(player.lives)"
        livesLabel.zPosition = GameData.drawOrder.hud
        
        
        fHealthLabel.fontColor = fontColor
        fHealthLabel.fontSize = fontSize
        fHealthLabel.position = CGPoint(x: marginH + 1150, y: playableRect.maxY - marginV)
        fHealthLabel.verticalAlignmentMode = .top
        fHealthLabel.horizontalAlignmentMode = .left
        fHealthLabel.text = "Enemy Health: \(fHealth)"
        fHealthLabel.zPosition = GameData.drawOrder.hud
        
        livesLabel.text = "Lives: \(player.lives)"
        livesLabel.zPosition = GameData.drawOrder.hud
        
        
        bombLaunchLabel.fontColor = fontColor
        bombLaunchLabel.fontSize = fontSize + 10
        bombLaunchLabel.position = CGPoint(x: marginH + 1600, y: playableRect.minY + marginV + 100)
        bombLaunchLabel.verticalAlignmentMode = .bottom
        bombLaunchLabel.horizontalAlignmentMode = .center
        
        bombLaunchLabel.name = "Bomb"
        bombLaunchLabel.text = "Launch!"
        //bombLaunchLabel.isUserInteractionEnabled = true
        bombLaunchLabel.zPosition = GameData.drawOrder.hud
        
        addChild(fHealthLabel)
        addChild(bombLaunchLabel)
        addChild(livesLabel)

        addChild(player)
        
        // set up buttons in the scene
        // PauseButton
        pauseButton = SKSpriteNode(imageNamed: "pause.png")
        pauseButton.position = CGPoint(x: marginH + 1800, y: playableRect.maxY - marginV - 80)
        pauseButton.zPosition = GameData.drawOrder.hud
        addChild(pauseButton)
        
        
        // checks to see if two objects collide
        physicsWorld.contactDelegate = self
        
        spaceEmitter.position = CGPoint(x:frame.width/2, y: frame.height/2)
        spaceEmitter.zPosition = GameData.drawOrder.bg
        addChild(spaceEmitter)
        
        addChild(pauseNode.node)
        
    }
    
    //MARK: -events-
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        //if(gameIsPaused){
        //    gameIsPaused = false
        //    return
        //} //else {
            //gameIsPaused = true
            //return
        //}
        
        //player movment
        if let touch = touches.first {
            tapY = touch.location(in: self).y
            player.isFiring = true
            
        }
        
        // launches the ship
        for touch: AnyObject in touches{
            let location = touch.location(in:self)
            if bombLaunchLabel.contains(location){
                if bombShip.canLaunch{
                    launchBomb()
                    print("BOMBING")
                    bombShip.canLaunch = false
                    
                    
                }
            }
            
            if pauseButton.contains(location){
                if(gameIsPaused){
                    gameIsPaused = false;
                } else{
                    gameIsPaused = true;
                }
            }
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
            tapY = touch.location(in: self).y
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.first != nil {
            tapY = nil
            player.isFiring = false
        }
    }
    
    func launchBomb(){
        addChild(bombShip)
        bombShip.approachEnemy()
    }
    
    func makeEnemies(){
        
        if(numEnemies + enemySpawnRate > 10 ){ return }
        
        numEnemies += enemySpawnRate
        
        var s:AlienSprite
        
        for _ in 0...enemySpawnRate-1{
            s = AlienSprite()
            s.name = "Enemy"
            
            s.position = randomCGPointInRect(enemyRect, margin: 50)
            
            addChild(s)
            
            // check physics body of sprite (Hopefully will collide with bullet)
            s.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width:30,height:50))
            s.physicsBody?.isDynamic = true
            s.physicsBody?.categoryBitMask = GameData.PhysicsCategory.Enemy
            s.physicsBody?.contactTestBitMask = GameData.PhysicsCategory.PlayerBullet
            s.physicsBody?.collisionBitMask = GameData.PhysicsCategory.None
            s.physicsBody?.usesPreciseCollisionDetection = true
            s.physicsBody?.affectedByGravity = false
        }
    }
    
    // spawns bullets into game
    func spawnBullet(){
        // only spawn if player is firing
        if player.isFiring{
             Bullet(isPlayer: true, spawnPoint: player.position, scene: self)
        }
        
    }
    
    // create a handler to check for bullet collision
    func playerBulletCollided(enemy:AlienSprite,bullet:SKSpriteNode){
        print("BOOM")
        enemy.health -= 1
        if enemy.health <= 0{
        enemy.removeFromParent()
            numEnemies -= 1;
        }
        bullet.removeFromParent()
    }
    
    func enemyBulletCollided(player:PlayerSprite,bullet:SKSpriteNode){
        print("BAM")
        player.lives -= 1
        livesLabel.text = "Lifes: \(player.lives)"
        if player.lives <= 0{
            player.removeFromParent()
            //TODO: end state
            let results = LevelResults(levelNum: 1, levelScore: 0, lives: 0, msg: "Game Over")
            sceneManager.loadGameOverScene(results: results)
            
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
        if ((firstBody.categoryBitMask & GameData.PhysicsCategory.PlayerBullet != 0) &&
            (secondBody.categoryBitMask & GameData.PhysicsCategory.Enemy != 0) &&
            firstBody.node != nil && secondBody.node != nil) {
            playerBulletCollided(enemy: secondBody.node as! AlienSprite, bullet: firstBody.node as! SKSpriteNode)
        }
        
        if ((firstBody.categoryBitMask & GameData.PhysicsCategory.Player != 0) &&
            (secondBody.categoryBitMask & GameData.PhysicsCategory.EnemyBullet != 0) &&
            firstBody.node != nil && secondBody.node != nil) {
            enemyBulletCollided(player: firstBody.node as! PlayerSprite, bullet: secondBody.node as! SKSpriteNode )
        }
        
    }

    //MARK: -Game Loop-
    
    func unpauseSprites(){
        let unpauseAction = SKAction.sequence([
            SKAction.wait(forDuration: 1),
            SKAction.run({self.spritesMoving = true})
        ])
        run(unpauseAction)
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
        
        if let y = tapY {
            
            let maxMove = GameData.player.shipMaxSpeedPerSecond * dt
            let close = abs(y - player.position.y) <= maxMove
            
            if(close){
                player.position.y = y
            } else {
                
                if(y > player.position.y){
                    player.position.y += maxMove
                } else {
                    player.position.y -= maxMove
                }
                
            }
            
            
            
        }
        
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
                
                if(s.position.y <= self.playableRect.minY + halfHeight || s.position.y >= self.playableRect.maxY - halfHeight) {
                    s.reflectY()
                    s.update(dt: dt)
                }
            })
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if(!gameIsPaused){
            calculateDeltaTime(currentTime: currentTime)
            moveSprites(dt: CGFloat(dt))
        }
    }
    
    }

//
//  GameScene.swift
//  shoter
//
//  Created by student on 9/22/16.
//  Copyright © 2016 djl1005. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    var levelNum:Int
    var levelScore:Int = 0 {
        didSet{
            scoreLabel.text = "Score: \(levelScore)"
        }
    }
    var totalScore:Int
    let sceneManager:GameViewController
    
    var tapCount = 0
    
    var playbleRect = CGRect.zero
    var totalSprites = 0
    
    let levelLabel = SKLabelNode(fontNamed: "Futura")
    let scoreLabel = SKLabelNode(fontNamed: "Futura")
    let otherLabel = SKLabelNode(fontNamed: "Futura")
    
    let player = PlayerSprite()
    
    var lastUpdateTime: TimeInterval = 0
    var dt: TimeInterval = 0
    var spritesMoving = false
    
    //MARK: - Init -
    
    init(size: CGSize, scaleMode:SKSceneScaleMode, levelNum:Int, totalScore:Int, sceneManager:GameViewController) {
        self.levelNum = levelNum
        self.totalScore = totalScore
        self.sceneManager = sceneManager
        super.init(size: size)
        self.scaleMode = scaleMode
    }
    
    required init?(coder aDecoder: NSCoder){
        fatalError("not implmented")
    }
    
    override func didMove(to view: SKView) {
        setupUI()
        makeSprites(howMany: 10)
        unpauseSprites()
    }
    
    deinit {
        //TODO: set
    }
    
    private func setupUI(){
        playbleRect = getPlayableRectPhoneLandscape(size: size)
        let fontSize = GameData.hud.fontSize
        let fontColor = GameData.hud.fontColorWhite
        let marginH = GameData.hud.marginH
        let marginV = GameData.hud.marginV
        
        backgroundColor = GameData.hud.backgroundColor
        
        levelLabel.fontColor = fontColor
        levelLabel.fontSize = fontSize
        levelLabel.position = CGPoint(x: marginH, y: playbleRect.maxY - marginV)
        levelLabel.verticalAlignmentMode = .top
        levelLabel.horizontalAlignmentMode = .left
        
        levelLabel.text = "Level: \(levelNum)"
        addChild(levelLabel)
        
        scoreLabel.fontColor = fontColor
        scoreLabel.fontSize = fontSize
        
        scoreLabel.verticalAlignmentMode = .top
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.text = "Score: 000"
        let scoreLabelWidth = scoreLabel.frame.size.width
        
        scoreLabel.text = "Score: \(levelScore)"
        
        scoreLabel.position = CGPoint(x: playbleRect.maxX - scoreLabelWidth - marginH, y: playbleRect.maxY - marginV)
        addChild(scoreLabel)
        
        otherLabel.fontColor = fontColor
        otherLabel.fontSize = fontSize
        otherLabel.position = CGPoint(x: marginH, y: playbleRect.minY + marginV)
        otherLabel.verticalAlignmentMode = .bottom
        otherLabel.horizontalAlignmentMode = .left
        otherLabel.text = "Num Sprites: 0"
        addChild(otherLabel)
        
        player.position = CGPoint(x: 300, y: 540)
        player.zRotation = CGFloat(-M_PI * 0.5)
        addChild(player)
    }
    
    //MARK: -events-
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        tapCount += 1
        
        if tapCount < 3 {
            
            //player movment
        
            if let touch = touches.first {
                 player.position.y = touch.location(in: self).y
                 player.isFiring = true
                
                // spawns bullets infinitely
                run(SKAction.repeatForever(
                    SKAction.sequence([
                        SKAction.run(spawnBullet),
                        SKAction.wait(forDuration: 0.75),
                        ])
                ))
            }
            
            return
        }
        
        if levelNum < GameData.maxLevel{
            totalScore += levelScore
            let results = LevelResults(levelNum: levelNum, levelScore: levelScore, totalScore: totalScore, msg: "you finished level \(levelNum)")
            sceneManager.loadLevelFinishScene(results: results)
        } else {
            totalScore += levelScore
            let results = LevelResults(levelNum: levelNum, levelScore: levelScore, totalScore: totalScore, msg: "you finished level \(levelNum)")
           sceneManager.loadGameOverScene(results: results)
        }
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
    
    func makeSprites(howMany:Int){
        totalSprites += howMany
        otherLabel.text = "Num Sprites: \(totalSprites)"
        
        var s:DiamondSprite
        
        for _ in 0...howMany-1{
            s = DiamondSprite(size: CGSize(width: 60, height: 100), lineWidth: 10, strokeColor: SKColor.green, fillColor: SKColor.magenta)
            s.name = "diamond"
            s.position = randomCGPointInRect(playbleRect, margin: 300)
            s.fwd = CGPoint.randomUnitVector()
            addChild(s)
        }
    }
    
    // spawns bullets into game
    func spawnBullet(){
        // only spawn if player is firing
        if player.isFiring{
            
            // set up spawn location
            let bullet = SKSpriteNode(imageNamed:"bullet.png")
            
            bullet.position = CGPoint(x: player.position.x, y: player.position.y)
            bullet.zRotation = CGFloat(-M_PI * 0.5)
            bullet.size = CGSize(width: bullet.size.width/2, height: bullet.size.height/2)
            
            // add bullet into gamescene
            addChild(bullet)
            
            
            // how long until bullet reaches destination?
            let bulletLifeTime = CGFloat(3.0)
            
            // arbitrary X for the moment
            let actionMove = SKAction.move(to: CGPoint(x: 1000, y: player.position.y), duration: TimeInterval(bulletLifeTime))
            
            let actionMoveDone = SKAction.removeFromParent()
            
            // run actions above
            bullet.run(SKAction.sequence([actionMove, actionMoveDone]))
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
            enumerateChildNodes(withName: "diamond", using: {node, stop in
                let s = node as! DiamondSprite
                let halfWidth = s.frame.width/2
                let halfHeight = s.frame.height/2
                
                s.update(dt: dt)
                
                if(s.position.x <= halfWidth || s.position.x >= self.size.width - halfWidth){
                    s.reflectX()
                    s.update(dt: dt)
                    self.levelScore += 1
                }
                
                if(s.position.y <= self.playbleRect.minY + halfHeight || s.position.y >= self.playbleRect.maxY - halfHeight) {
                    s.reflectY()
                    s.update(dt: dt)
                    self.levelScore += 1
                }
            })
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        calculateDeltaTime(currentTime: currentTime)
        moveSprites(dt: CGFloat(dt))
    }
    
    }

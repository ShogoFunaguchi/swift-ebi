//
//  GameScene.swift
//  ebi
//
//  Created by Shogo Funaguchi on 2017/06/30.
//  Copyright © 2017年 Shogo Funaguchi. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // プレイヤーキャラのアニメーション用
    
    struct Constants {
        static let PlayerImages = ["shrimp01", "shrimp02", "shrimp03", "shrimp04"]
    }
    
    
    // 当たり判定用
    struct ColliderType {
        static let Player: UInt32 = (1 << 0)
        static let World: UInt32  = (1 << 1)
        static let Coral: UInt32  = (1 << 2)
        static let Score: UInt32  = (1 << 3)
        static let None:  UInt32  = (1 << 4)
    }
    
    var baseNode: SKNode!
    var coralNode: SKNode!
    var player: SKSpriteNode!
    var scoreLabelNode: SKLabelNode!
    var score: UInt32!

    
    override func didMove(to view: SKView) {
        
        score = 0
        self.physicsWorld.gravity = CGVector(dx: 0.0, dy: -2.0)
        self.physicsWorld.contactDelegate = self
        
        baseNode = SKNode()
        baseNode.speed = 1.0
        
        self.addChild(baseNode)
        
        coralNode = SKNode()
        baseNode.addChild(coralNode)
        
        self.setupBackGroundSea()
        self.setupRock()
        self.setupCeilingAndLand()
        self.setupPlayer()
        self.setupCoral()
        self.setupScoreLabel()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if 0.0 < baseNode.speed {
            for touch: AnyObject in touches {
//                let location = touch.location
                player.physicsBody?.velocity = CGVector.zero
                player.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: 23.0))
                
            }
        }
        else if baseNode.speed == 0.0 && player.speed == 0.0 {
            coralNode.removeAllChildren()
            score = 0
            scoreLabelNode.text = String(score)
            
            player.position = CGPoint(x: self.frame.size.width * 0.35, y: self.frame.size.height * 0.6)
            
            player.physicsBody?.velocity = CGVector.zero
            player.physicsBody?.collisionBitMask = ColliderType.World | ColliderType.Coral
            player.zRotation = 0.0
            player.speed = 1.0
            baseNode.speed = 1.0
        }

    }
    
    // 当たり判定
    func didBegin(_ contact: SKPhysicsContact) {
        // 当たったどちらかがScore判定用のオブジェクトだったら
        let rawScoreType = ColliderType.Score
        let rawNoneType = ColliderType.Score
        
        if (contact.bodyA.categoryBitMask & rawScoreType) == rawScoreType ||
           (contact.bodyB.categoryBitMask & rawScoreType) == rawScoreType {
            
            score = score + 1
            scoreLabelNode.text = String(score)
            
            
            
            let scoreUpAnim = SKAction.scale(to: 1.5, duration: 0.1)
            let scoreDownAnim = SKAction.scale(to: 1.0, duration: 0.1)
            scoreLabelNode.run(SKAction.sequence([scoreUpAnim, scoreDownAnim]))
            
            
            if (contact.bodyA.categoryBitMask & rawScoreType) == rawScoreType {
                contact.bodyA.categoryBitMask = rawNoneType
                contact.bodyA.contactTestBitMask = rawNoneType
            }
            else {
                contact.bodyB.categoryBitMask = rawNoneType
                contact.bodyB.contactTestBitMask = rawNoneType
            }
        }
        else if (contact.bodyA.categoryBitMask & rawNoneType) == rawNoneType ||
                 (contact.bodyB.categoryBitMask & rawNoneType) == rawNoneType {
    
        }
        else {
            baseNode.speed = 0.0
            // ビットマスクを天井と床に変更
            player.physicsBody?.collisionBitMask = ColliderType.World
            let rolling = SKAction.rotate(byAngle: CGFloat(Double.pi)*player.position.y*0.01, duration: 1.0)
            player.run(rolling, completion: {
                self.player.speed = 0.0
            })
        }
    }
    
    func setupBackGroundSea() {
        
        let texture = SKTexture(imageNamed: "background")
        texture.filteringMode = .nearest
        
        
        let needNumber = 2.0 + (self.frame.size.width / texture.size().width)
        
        let moveAnimation = SKAction.moveBy(
            x: -texture.size().width,
            y: 0.0,
            duration: TimeInterval(texture.size().width / 10.0)
        )
        
        let resetAnimation = SKAction.moveBy(x: texture.size().width, y: 0.0, duration: 0.0)
        let repeatForeverAnimation = SKAction.repeatForever(SKAction.sequence([moveAnimation, resetAnimation]))
        
        
        for i in stride(from: 0, to: needNumber, by: 1.0){
            
            let sprite = SKSpriteNode(texture: texture)
            
            sprite.zPosition = -100.0
            sprite.position = CGPoint(x: i * sprite.size.width, y: self.frame.size.height/2.0)
            sprite.run(repeatForeverAnimation)
            baseNode.addChild(sprite)
        }
        
    }
    
    func setupRock() {
     
        let bottom = SKTexture(imageNamed: "rock_under")
        bottom.filteringMode = .nearest
        
        var needNumber = 2.0 + (self.frame.size.width / bottom.size().width)
        
        let brAnim = SKAction.moveBy(
            x: -bottom.size().width,
            y: 0.0,
            duration: TimeInterval(bottom.size().width/20.0)
        )
        
        let brAnimReset = SKAction.moveBy(
            x: bottom.size().width,
            y: 0.0,
            duration: 0.0
        )
        
        let brAnimForever = SKAction.repeatForever(SKAction.sequence([brAnim, brAnimReset]))
        
        for i in stride(from: 0.0, to: needNumber, by: 1.0) {
            let sprite = SKSpriteNode(texture: bottom)
            sprite.zPosition = -50
            sprite.position = CGPoint(x: i * sprite.size.width, y: sprite.size.height / 2)
            sprite.run(brAnimForever)
            baseNode.addChild(sprite)
        }
        
        
        let top = SKTexture(imageNamed: "rock_above")
        top.filteringMode = .nearest
        
        needNumber = 2.0 + (self.frame.size.width / top.size().width)
        
        
        let trAnim = SKAction.moveBy(x: -top.size().width, y: 0.0, duration: TimeInterval(top.size().width/20.0) )
        let trAnimReset = SKAction.moveBy(x: top.size().width, y: 0.0, duration: 0.0)
        let trAnimForever = SKAction.repeatForever(SKAction.sequence([trAnim, trAnimReset]))
        
        for i in stride(from: 0.0, to: needNumber, by: 1.0) {
            let sprite = SKSpriteNode(texture: top)
            sprite.position = CGPoint(x: i*sprite.size.width, y: (self.frame.height - sprite.size.height/2))
            
            sprite.zPosition = -50
            sprite.run(trAnimForever)
            baseNode.addChild(sprite)
        }
    }
    
    func setupCeilingAndLand() {
        
        // 床のセットアップ
        let land = SKTexture(imageNamed: "land")
        land.filteringMode = .nearest
        
        var needPicture = 2.0 + (self.frame.size.width / land.size().width)
        
        let landAnim = SKAction.moveBy(x: -land.size().width, y: 0.0, duration: TimeInterval(land.size().width/100.0))
        let landAnimReset = SKAction.moveBy(x: land.size().width, y: 0.0, duration: 0.0)
        let landRepeat = SKAction.repeatForever(SKAction.sequence([landAnim, landAnimReset]))
        
        
        for i in stride(from: 0.0, to: needPicture, by: 1.0) {
            
            let sprite = SKSpriteNode(texture: land)
            
            sprite.position = CGPoint(x: i*sprite.size.width, y: sprite.size.height/2)
            sprite.zPosition = -10
            
            // 物理シュミレーションを設定
            sprite.physicsBody = SKPhysicsBody(texture: land, size: land.size())
            sprite.physicsBody?.isDynamic = false
            sprite.physicsBody?.categoryBitMask = ColliderType.World
            
            sprite.run(landRepeat)
            baseNode.addChild(sprite)
        }
        
        // 天井のセットアップ
        
        let ceiling = SKTexture(imageNamed: "ceiling")
        ceiling.filteringMode = .nearest
        
        needPicture = 2.0 + (self.frame.size.width / ceiling.size().width)
        
        let ceilingAnim = SKAction.moveBy(x: -ceiling.size().width, y: 0.0, duration: TimeInterval(ceiling.size().width/100.0))
        
        let ceilingAnimReset = SKAction.moveBy(x: ceiling.size().width, y: 0.0, duration: 0.0)
        
        let ceilingAnimForever = SKAction.repeatForever(SKAction.sequence([ceilingAnim, ceilingAnimReset]))
        
        for i in stride(from: 0.0, to: needPicture, by: 1.0) {
            let sprite = SKSpriteNode(texture: ceiling)
            sprite.position = CGPoint(x: i*sprite.size.width, y: self.frame.size.height - sprite.size.height/2)
            sprite.zPosition = -10
            
            sprite.physicsBody = SKPhysicsBody(texture: ceiling, size: ceiling.size())
            sprite.physicsBody?.isDynamic = false
            sprite.physicsBody?.categoryBitMask = ColliderType.World
            
            sprite.run(ceilingAnimForever)
            baseNode.addChild(sprite)
        }
    }// setupCeilingAndLand
    
    func setupPlayer() {
        
        // Playerのテクスチャ−の配列を作成
        var playerTexture = [SKTexture]()
        for imageName in Constants.PlayerImages {
            let texture = SKTexture(imageNamed: imageName)
            texture.filteringMode = .linear
            playerTexture.append(texture)
        }
        
        let playerAnimation = SKAction.animate(with: playerTexture, timePerFrame: 0.2)
        let playerLoopAnim = SKAction.repeatForever(playerAnimation)
        
        player = SKSpriteNode(texture: playerTexture[0])
        player.position = CGPoint(x: self.frame.size.width*0.35, y: self.frame.size.height*0.6)
        
        player.physicsBody = SKPhysicsBody(texture: playerTexture[0], size: playerTexture[0].size())
        
        player.physicsBody?.isDynamic = true // 世界から重力の影響を受けるか？
        player.physicsBody?.allowsRotation = false // 物理的にぶつかったら、回転するか？
        
        // 衝突検知周りの設定
        // プレイヤーのビットマスクカテゴリを設定
        player.physicsBody?.categoryBitMask = ColliderType.Player
        
        // どのオブジェクトと衝突したことを検知するか
        player.physicsBody?.collisionBitMask = ColliderType.World | ColliderType.Coral
        
        // 衝突判定をする。
        player.physicsBody?.contactTestBitMask = ColliderType.World | ColliderType.Coral
        
        player.run(playerLoopAnim)
        
        self.addChild(player)
        
        
    }// setupPlayer
    
    
    func setupCoral() {
        
        let coralUnder = SKTexture(imageNamed: "coral_under")
        coralUnder.filteringMode = .linear
        let coralAbove = SKTexture(imageNamed: "coral_above")
        coralAbove.filteringMode = .linear
        
        let distanceToMove = CGFloat(self.frame.size.width + 2.0 * coralUnder.size().width)
        
        let moveAnim = SKAction.moveBy(x: -distanceToMove, y: 0.0, duration: TimeInterval(distanceToMove / 100.0))
        let removeAnim = SKAction.removeFromParent()
        let coralAnim = SKAction.sequence([moveAnim, removeAnim])
        
        let newCoralAnim = SKAction.run({
            let coral = SKNode()
            coral.position = CGPoint(x: self.frame.width + coralUnder.size().width*2, y: 0.0)
            
            let height = UInt32(self.frame.size.height / 12) // 画面の高さを12分割したものを基準にする
            let y = CGFloat(arc4random_uniform(height*2)) // 画面の 2/12　を超えないランダムな値を取得
            
            let under = SKSpriteNode(texture: coralUnder)
            under.position = CGPoint(x: 0.0, y: y)
            under.zPosition = -11
            
            under.physicsBody = SKPhysicsBody(texture: coralUnder, size: under.size)
            under.physicsBody?.isDynamic = false
            under.physicsBody?.categoryBitMask = ColliderType.Coral
            under.physicsBody?.contactTestBitMask = ColliderType.Player
            coral.addChild(under)
            
            
            let above = SKSpriteNode(texture: coralAbove)
            above.position = CGPoint(x: 0.0, y: y+(under.size.height / 2.0) + 160.0 + (above.size.height / 2.0))
            above.zPosition = -11
            
            above.physicsBody = SKPhysicsBody(texture: coralAbove, size: above.size)
            above.physicsBody?.isDynamic = false
            above.physicsBody?.categoryBitMask = ColliderType.Coral
            above.physicsBody?.contactTestBitMask = ColliderType.Player
            coral.addChild(above)
            
            let scoreNode = SKNode()
            scoreNode.position = CGPoint(x: (above.size.width / 2.0) + 5.0, y: self.frame.height / 2.0)
            
            scoreNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 10.0, height: self.frame.size.height))
            scoreNode.physicsBody?.isDynamic = false
            scoreNode.physicsBody?.categoryBitMask = ColliderType.Score
            scoreNode.physicsBody?.contactTestBitMask = ColliderType.Player
            coral.addChild(scoreNode)
            
            coral.run(coralAnim)
            self.coralNode.addChild(coral)
            
        })
        
        let delayAnim = SKAction.wait(forDuration: 2.5)
        let repeatForeverAnim = SKAction.repeatForever(SKAction.sequence([newCoralAnim, delayAnim]))
        self.run(repeatForeverAnim)
    } // setupCoral
    
    func setupScoreLabel() {
        scoreLabelNode = SKLabelNode(fontNamed: "Arial Bold")
        scoreLabelNode.fontColor = UIColor.black
        scoreLabelNode.position = CGPoint(x: self.frame.size.width/2.0, y: self.frame.size.height*0.9)
        scoreLabelNode.zPosition = 100.0
        scoreLabelNode.text = String(score)
        
        self.addChild(scoreLabelNode)
    }
    
    
    func resetPlayer() {
        var playerTexture = [SKTexture]()
        
        for imageName in Constants.PlayerImages {
            let texture = SKTexture(imageNamed: imageName)
            playerTexture.append(texture)
        }
        
        let playerAnim = SKAction.animate(with: playerTexture, timePerFrame: 0.2)
        let loopAnim = SKAction.repeatForever(playerAnim)
        
        player.position = CGPoint(x: self.frame.size.width*0.35, y: self.frame.size.height*0.6)
        
        player.speed = 1.0
        player.run(loopAnim)
        
        
    }

}

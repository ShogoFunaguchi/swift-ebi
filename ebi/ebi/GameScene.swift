//
//  GameScene.swift
//  ebi
//
//  Created by Shogo Funaguchi on 2017/06/30.
//  Copyright © 2017年 Shogo Funaguchi. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    var baseNode: SKNode!
    var coralNode: SKNode!
    
    override func didMove(to view: SKView) {
        
        baseNode = SKNode()
        baseNode.speed = 1.0
        
        self.addChild(baseNode)
        
        coralNode = SKNode()
        baseNode.addChild(coralNode)
        
        self.setupBackGroundSea()
    }
    

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
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
    
    
//    func setupBackGroundSea() {
//        
//        let texture = SKTexture(imageNamed: "background")
//    }
    
}

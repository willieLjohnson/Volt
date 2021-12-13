//
//  Enemy.swift
//  dashable
//
//  Created by Willie Johnson on 3/13/18.
//  Copyright © 2018 Willie Johnson. All rights reserved.
//

import SpriteKit

/// The Enemy SKSpriteNode that handles enemy logic.
class Enemy: Actor {
    /// How fast the enemy was moving on the last update.
    var previousVelocity: CGVector = .zero
    /// How far the enemy can see.
    var viewDistance: CGSize = CGSize(width: 100, height: 0)
    /// The logic the enemy will execute on each frame.
    var logic: EnemyLogic?
    /// Tracks whether or not an SKAction is running on the Enemy.
    var isAbilityActionRunning: Bool = false
    
    var moveSpeed: CGFloat = 10000.0
    var health: Int = 50
    var canEvolve: Bool = true
    
    func evolve(_ scene: GameScene) {
        canEvolve = false
        
        //    for _ in 0...3 {
        //        scene.addBee(position: body.sprite.)
        //    }
        EntityManager.shared.remove(entity: self)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(name: String, position: CGPoint, color: SKColor, size: CGSize) {
        super.init(name: name, color: color, size: size)
        getBody().sprite.position = position
    }
    
    required init() {
        super.init(name: Names.Collidable.Actor.Enemy.CHASER, color: Style.PLAYER_COLOR, size: Player.SIZE)
    }
    
    
    /// Update state.
    func update(_ scene: GameScene) {
        // Grab player.
        guard let player = scene.player else { return }
        guard let logic = logic else { return }
        logic(self, player, scene)
        
        if health <= 0 {
            if canEvolve {
                evolve(scene)
            } else {
                scene.remove(deadEnemy: self)
                //        die()
            }
        }
    }
    
    func damage(amount: Int = 1) {
        health -= amount
    }
    
    func onContact(with: SKNode) {
        print("Tag!")
    }
}

extension Enemy {
    static func createChaser(position: CGPoint, size: CGSize = CGSize(width: 60, height:  60)) -> Enemy {
        let chaser = Enemy(name: Names.Collidable.Actor.Enemy.CHASER, position: position, color: Style.CHASER_COLOR, size: size)
        if let physicsBody = chaser.getPhysicsBody() {
            physicsBody.contactTestBitMask = PhysicsCategory.obstacles
        }
        chaser.logic = Logic.chaserLogic
        return chaser
    }
    
    static func createBee(position: CGPoint) -> Enemy {
        let bee = createChaser(position: position, size: CGSize(width: 30, height: 30))
//        bee.color = Style.BEE_COLOR
//        bee.name = "bee"
//        bee.health = 20;
//        bee.canEvolve = false
//        bee.physicsBody!.contactTestBitMask = PhysicsCategory.player
//        bee.physicsBody!.collisionBitMask = bee.physicsBody!.collisionBitMask | PhysicsCategory.enemy
//        bee.physicsBody!.density = 2
//        bee.moveSpeed = 1000.0
        return bee
    }
    
}

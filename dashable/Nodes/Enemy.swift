//
//  Enemy.swift
//  dashable
//
//  Created by Willie Johnson on 3/13/18.
//  Copyright © 2018 Willie Johnson. All rights reserved.
//

import SpriteKit

/// The Enemy SKSpriteNode that handles enemy logic.
class Enemy: SKSpriteNode, Entity {
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

  required init(position: CGPoint, size: CGSize, color: SKColor, categoryMask: UInt32 = PhysicsCategory.enemy) {
    super.init(texture: nil, color: color, size: size)
    self.position = position
    self.zPosition = 10
    name = "enemy"

    physicsBody = SKPhysicsBody(rectangleOf: size)
    if let physicsBody = physicsBody {
      physicsBody.affectedByGravity = true
      physicsBody.categoryBitMask = PhysicsCategory.enemy
      physicsBody.collisionBitMask =
        PhysicsCategory.ground |
        PhysicsCategory.player |
        PhysicsCategory.projectile |
        PhysicsCategory.obstacles |
        PhysicsCategory.enemy
      physicsBody.usesPreciseCollisionDetection = true
      physicsBody.density = 8
    }
//    self.addGlow()
  }

  func move(velocity: CGVector) {
    guard let physicsBody = physicsBody else { return }
    physicsBody.applyImpulse(velocity)
  }

  func evolve(_ scene: GameScene) {
    canEvolve = false

    for _ in 0...3 {
      scene.addBee(position: position)
    }
    removeFromParent()
  }


  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
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
     let chaser = Enemy(position: position, size: size, color: Style.CHASER_COLOR)
     chaser.physicsBody?.contactTestBitMask = PhysicsCategory.obstacles
     chaser.logic = Logic.chaserLogic
     return chaser
   }

  static func createBee(position: CGPoint) -> Enemy {
    let bee = createChaser(position: position, size: CGSize(width: 30, height: 30))
    bee.color = Style.BEE_COLOR
    bee.name = "bee"
    bee.health = 20;
    bee.canEvolve = false
    bee.physicsBody!.contactTestBitMask = PhysicsCategory.player
    bee.physicsBody!.collisionBitMask = bee.physicsBody!.collisionBitMask | PhysicsCategory.enemy
    bee.physicsBody!.density = 2
    bee.moveSpeed = 1000.0
    return bee
  }

}

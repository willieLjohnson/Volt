//
//  Enemy.swift
//  dashable
//
//  Created by Willie Johnson on 3/13/18.
//  Copyright © 2018 Willie Johnson. All rights reserved.
//

import SpriteKit
import GameplayKit

/// The Enemy SKSpriteNode that handles enemy logic.
class Enemy: Entity {
  var previousVelocity: CGVector = .zero
  /// How far the enemy can see.
  var viewDistance: CGSize = CGSize(width: 100, height: 100)

  /// Tracks whether or not an SKAction is running on the Enemy.
  override func onInit() {
    super.onInit()
    name = "enemy"
    updateGlow()
  }
  
  /// Update state.
  override func update(deltaTime: TimeInterval) {
    super.update(deltaTime: deltaTime)
  }
  
  
  override func beforeDie() {
    guard let game = game else { return }
    game.remove(deadEnemy: self)
  }
  
  override func die(afterDie: (() -> ())? = nil) {
    super.die(afterDie: afterDie != nil ? afterDie : {
      self.evolve()
    })
  }
  
  func evolve() {
    guard let evolveComponent = component(ofType: EvolveComponent.self) as? EvolveComponent else { return }
    evolveComponent.evolve()
  }
}

extension Enemy {
  static func createChaser(position: CGPoint, size: CGSize = CGSize(width: 60, height:  60), game: GameScene? = nil) -> Enemy {
    let chaser = Enemy(size: size, color: Style.CHASER_COLOR, position: position, game: game)
    let _ = [
        MoveComponent(entity: chaser, moveSpeed: 500),
        HealthComponent(entity: chaser, health: 25),
        EvolveComponent(entity: chaser, canEvolve: true, onEvolveHandler: { enemy in
          guard let game = chaser.game else { return }
          EvolveComponent.component(from: chaser).canEvolve = false
          for _ in 0...3 {
            game.addBee(position: position)
          }
        }),
        WeaponComponent(entity: chaser),
        CollisionComponent(entity: chaser, category: PhysicsCategory.enemy, density: 8),

      ].map {
        chaser.addComponent(component: $0)
      }
     return chaser
   }

  static func createBee(position: CGPoint, game: GameScene? = nil) -> Enemy {
    let bee = createChaser(position: position, size: CGSize(width: 30, height: 30), game: game)
    bee.color = Style.BEE_COLOR
    bee.name = "bee"
    HealthComponent.component(from: bee).health = 5
    EvolveComponent.component(from: bee).canEvolve = false
    bee.physicsBody!.contactTestBitMask = PhysicsCategory.player
    bee.physicsBody!.collisionBitMask = bee.physicsBody!.collisionBitMask | PhysicsCategory.enemy
    bee.physicsBody!.density = 2
    MoveComponent.component(from: bee).setBase(moveSpeed: 800)
    return bee
  }

  static func createFlyer(position: CGPoint, game: GameScene? = nil) -> Enemy {
    let flyer = createChaser(position: position, size: CGSize(width: 200, height: 200), game: game)
    HealthComponent.component(from: flyer).health  *= 1000
    flyer.color = Style.FLYER_COLOR
    MoveComponent.component(from: flyer).setBase(moveSpeed: 1700)
    flyer.name = "flyer"
    flyer.physicsBody!.collisionBitMask = PhysicsCategory.projectile
    flyer.physicsBody!.categoryBitMask = PhysicsCategory.flyerEnemy

    return flyer
  }
}

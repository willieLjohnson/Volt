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
  }
  
  /// Update state.
  override func update(_ deltaTime: TimeInterval?) {
    super.update(deltaTime)
  }
  
  
  override func beforeDecomposing() {
    guard let game = game else { return }
    game.remove(deadEnemy: self)
  }
  
  override func decompose(afterDecomposing: (() -> ())? = nil) {
    super.decompose(afterDecomposing: afterDecomposing != nil ? afterDecomposing : {
      self.evolve()
    })
  }
  
  func evolve() {
    guard let evolveComponent = component(ofType: EvolveComponent.self) as? EvolveComponent else { return }
    evolveComponent.evolve()
  }
}

extension Enemy {
  static func createEnemy(position: CGPoint, size: CGSize = CGSize(width: 4, height:  4), game: GameScene? = nil) -> Enemy {
    var enemy = Enemy(size: size, color: Style.CHASER_COLOR, position: position, game: game)
    _ = [
      MoveComponent(entity: enemy, moveSpeed: 0.02),
      HealthComponent(entity: enemy, health: 25),
      CollisionComponent(entity: enemy, category: PhysicsCategory.enemy, density: 2),
      TargetComponent(entity: enemy, target: game != nil ? game!.player : nil),
      WeaponComponent(entity: enemy),
      EvolveComponent(entity: enemy, canEvolve: true),
      ActionComponent<Enemy>(entity: enemy),
    ].map {
      enemy.add(component: $0)
    }
    return enemy
  }
  
  static func createChaser(position: CGPoint, size: CGSize = CGSize(width: 4, height:  4), game: GameScene? = nil) -> Enemy {
    let chaser = createEnemy(position: position, size: size, game: game)
    EvolveComponent.component(from: chaser).onEvolveHandler = { enemy in
      guard let game = enemy.game else { return }
      for _ in 0...3 {
        game.addBee(position: enemy.position)
      }
    }
    ActionComponent<Enemy>.component(from: chaser).machine = EnemyAction(agent: chaser, actions: [
      CombatState(agent: chaser, actions: [
        Chasing(agent: chaser)
      ]),
    ]).executing(CombatState.self)
    
    return chaser
  }

  static func createBee(position: CGPoint, game: GameScene? = nil) -> Enemy {
    var bee = createChaser(position: position, size: CGSize(width: 3, height: 3), game: game)
    bee.color = Style.BEE_COLOR
    bee.name = "bee"
    bee.physicsBody!.contactTestBitMask = PhysicsCategory.player
    bee.physicsBody!.collisionBitMask = bee.physicsBody!.collisionBitMask | PhysicsCategory.enemy
    bee.physicsBody!.density = 1
    
    HealthComponent.component(from: bee).health = 5
//    MoveComponent.component(from: bee).setBase(moveSpeed: 0.1)
    bee.remove(componentOf: EvolveComponent.self)
    return bee
  }

  static func createFlyer(position: CGPoint, game: GameScene? = nil) -> Enemy {
    let flyer = createEnemy(position: position, size: CGSize(width: 5, height: 5), game: game)
    flyer.color = Style.FLYER_COLOR
    flyer.name = "flyer"
    flyer.physicsBody!.collisionBitMask = PhysicsCategory.projectile
    flyer.physicsBody!.categoryBitMask = PhysicsCategory.flyerEnemy
    HealthComponent.component(from: flyer).health  *= 1000
    MoveComponent.component(from: flyer).setBase(moveSpeed: 0.5)
    WeaponComponent.component(from: flyer).attackRange = 10
    ActionComponent<Enemy>.component(from: flyer).machine = EnemyAction(agent: flyer, actions: [
      CombatState(agent: flyer, actions: [
        Chasing(agent: flyer, movementType: .Match(2))
      ]),
    ])
    
    return flyer
  }
}

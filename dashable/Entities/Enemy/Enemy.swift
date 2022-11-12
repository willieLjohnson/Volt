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
  static func createEnemy(position: CGPoint, size: CGSize = CGSize(width: 60, height:  60), game: GameScene? = nil) -> Enemy {
    let enemy = Enemy(size: size, color: Style.CHASER_COLOR, position: position, game: game)
    _ = [
      MoveComponent(entity: enemy, moveSpeed: 500),
      HealthComponent(entity: enemy, health: 25),
      CollisionComponent(entity: enemy, category: PhysicsCategory.enemy, density: 8),
      TargetComponent(entity: enemy, target: game != nil ? game!.player : nil),
      WeaponComponent(entity: enemy),
      EvolveComponent(entity: enemy, canEvolve: true),
      LogicComponent(entity: enemy)
    ].map {
      enemy.addComponent(component: $0)
    }
    return enemy
  }
  
  static func createChaser(position: CGPoint, size: CGSize = CGSize(width: 60, height:  60), game: GameScene? = nil) -> Enemy {
    let chaser = createEnemy(position: position, size: size, game: game)
    EvolveComponent.component(from: chaser).onEvolveHandler = { enemy in
      guard let game = enemy.game else { return }
      EvolveComponent.component(from: enemy).canEvolve = false
      for _ in 0...3 {
        game.addBee(position: position)
      }
    }
    LogicComponent.component(from: chaser).logic = EnemyLogic(enemy: chaser, states: [
      ChaseState(enemy: chaser, logicHandler: EnemyLogicConstants.chaserLogic),
      AttackState(enemy: chaser, logicHandler: nil)
    ]).entered(ChaseState.self)
    return chaser
  }

  static func createBee(position: CGPoint, game: GameScene? = nil) -> Enemy {
    let bee = createChaser(position: position, size: CGSize(width: 30, height: 30), game: game)
    bee.color = Style.BEE_COLOR
    bee.name = "bee"
    bee.physicsBody!.contactTestBitMask = PhysicsCategory.player
    bee.physicsBody!.collisionBitMask = bee.physicsBody!.collisionBitMask | PhysicsCategory.enemy
    bee.physicsBody!.density = 2
    
    HealthComponent.component(from: bee).health = 5
    EvolveComponent.component(from: bee).canEvolve = false
    MoveComponent.component(from: bee).setBase(moveSpeed: 800)
    return bee
  }

  static func createFlyer(position: CGPoint, game: GameScene? = nil) -> Enemy {
    let flyer = createEnemy(position: position, size: CGSize(width: 200, height: 200), game: game)
    flyer.color = Style.FLYER_COLOR
    flyer.name = "flyer"
    flyer.physicsBody!.collisionBitMask = PhysicsCategory.projectile
    flyer.physicsBody!.categoryBitMask = PhysicsCategory.flyerEnemy
    HealthComponent.component(from: flyer).health  *= 1000
    MoveComponent.component(from: flyer).setBase(moveSpeed: 1700)
    LogicComponent.component(from: flyer).logic = EnemyLogic(enemy: flyer, states: [
      ChaseState(enemy: flyer, logicHandler: EnemyLogicConstants.flyerLogic),
      AttackState(enemy: flyer, logicHandler: nil)
    ]).entered(ChaseState.self)
    return flyer
  }
}

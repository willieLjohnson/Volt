//
//  Enemy.swift
//  Volt
//
//  Created by Willie Johnson on 3/13/18.
//  Copyright © 2018 Willie Johnson. All rights reserved.
//

import SpriteKit
import GameplayKit

class Actor: Entity {
  weak var movement: MoveComponent? {
    MoveComponent.component(from: self)
  }
  weak var health: HealthComponent? {
    HealthComponent.component(from: self)
  }
  weak var collider: CollisionComponent? {
    CollisionComponent.component(from: self)
  }
  weak var locus: LocusComponent? {
    LocusComponent.component(from: self)
  }

  init(name: String, size: CGSize, color: UIColor = .white, position: CGPoint = CGPoint(0), game: GameScene? = nil) {
    super.init(texture: nil, color: color, size: size)
    enter(game, position)
    generateComponents()
    onInit()
  }
  
  override func onInit() {
    super.onInit()
  }
  
  func generateComponents() {
    self.addComponents([
      MoveComponent(entity: self, moveSpeed: 0.01),
      HealthComponent(entity: self, health: 25),
      CollisionComponent(entity: self, category: PhysicsCategory.world),
      LocusComponent(entity: self, target: nil),
    ])
  }
    
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

class Enemy: Actor {
  var previousVelocity: CGVector = .zero
  var viewDistance: CGSize = CGSize(width: 100, height: 100)
  
  weak var evolver: EvolveComponent? {
    EvolveComponent.component(from: self)
  }
  
  weak var weapon: WeaponComponent? {
    WeaponComponent.component(from: self)
  }
  
  weak var behavior: ActionComponent<Enemy>? {
    ActionComponent<Enemy>(entity: self)
  }
  override func generateComponents() {
    super.generateComponents()
    self.addComponents([
      WeaponComponent(entity: self),
      EvolveComponent(entity: self, canEvolve: true),
    ])
    movement?.moveSpeed = 0.02
    collider?.physicsBody.density = 1
    locus?.target = game?.player
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
  static func createChaser(position: CGPoint, size: CGSize = CGSize(width: 4, height:  4), game: GameScene? = nil) -> Enemy {
    let chaser = Enemy(name: "chaser", size: size, position: position, game: game)
    
    chaser.evolver?.onEvolveHandler = { enemy in
      for _ in 0...3 {
        enemy?.game?.addBee(position: enemy?.position ?? .zero)
      }
    }
    chaser.behavior?.machine = EnemyAction(agent: chaser, actions: [
      CombatState(agent: chaser, actions: [
        Chasing(agent: chaser)
      ]),
    ]).executing(CombatState.self)
    
    return chaser
  }

  static func createBee(position: CGPoint, game: GameScene? = nil) -> Enemy {
    let bee = createChaser(position: position, size: CGSize(width: 3, height: 3), game: game)
    bee.color = Theme.bee
    bee.name = "bee"
    bee.physicsBody!.contactTestBitMask = PhysicsCategory.player
    bee.physicsBody!.collisionBitMask = bee.physicsBody!.collisionBitMask | PhysicsCategory.enemy
    bee.physicsBody!.density = 1
    
    HealthComponent.component(from: bee).current = 5
//    MoveComponent.component(from: bee).setBase(moveSpeed: 0.1)
    bee.remove(componentOf: EvolveComponent.self)
    return bee
  }

  static func createFlyer(position: CGPoint, game: GameScene? = nil) -> Enemy {
    let flyer = Enemy(name: "flyer", size: CGSize(width: 5, height: 5), position: position, game: game)
    flyer.color = Theme.flyer
    flyer.collider?.physicsBody.collisionBitMask = PhysicsCategory.projectile
    flyer.collider?.physicsBody.categoryBitMask = PhysicsCategory.flyerEnemy
    flyer.health?.current *= 1000
    flyer.movement?.setBase(moveSpeed: 0.5)
    flyer.weapon?.attackRange = 10
    flyer.behavior?.machine = EnemyAction(agent: flyer, actions: [
      CombatState(agent: flyer, actions: [
        Chasing(agent: flyer, movementType: .Match(2))
      ]),
    ])
    
    return flyer
  }
}

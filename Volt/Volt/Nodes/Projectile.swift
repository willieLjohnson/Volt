//
//  Projectile.swift
//  Projectile
//
//  Created by Willie JohOnson on 11/20/21.
//  Copyright © 2021 Willie Johnson. All rights reserved.
//

import Foundation

import SpriteKit

class Projectile: Entity {
  var health: Int = 1
  var moveSpeed: CGFloat = 1
  var canEvolve: Bool = false
  let initialSpeed: CGFloat = 0.3

  init(position: CGPoint, size: CGFloat, color: SKColor = Theme.projectile) {
    super.init(texture: nil, color: Theme.obstacle, size: CGSize(width: size * 0.6, height: size * 1.4))
    self.position = position
    self.color = color

    name = GameConstants.ProjectileName
    physicsBody = SKPhysicsBody(circleOfRadius: size)

    guard let physicsBody = physicsBody else { return }
    physicsBody.density = 1
    physicsBody.affectedByGravity = false
    physicsBody.isDynamic = true
    physicsBody.usesPreciseCollisionDetection = true
    physicsBody.categoryBitMask = PhysicsCategory.projectile
    physicsBody.collisionBitMask = PhysicsCategory.enemy | PhysicsCategory.world | PhysicsCategory.obstacles | PhysicsCategory.flyerEnemy
    physicsBody.contactTestBitMask = PhysicsCategory.enemy | PhysicsCategory.obstacles | PhysicsCategory.flyerEnemy
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func startDecay() {
    let scale = SKAction.scale(to: 0, duration: 2)
    run(scale, completion: { self.removeFromParent() })
  }

}

extension Projectile {
  func move(velocity: CGVector) {
    return
  }
  
  func update(_ scene: GameScene) {
    return
  }
  
  func onContact(with: SKNode) {
    return
  }
}

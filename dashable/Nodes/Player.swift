//
//  Player.swift
//  dashable
//
//  Created by Willie Johnson on 3/8/18.
//  Copyright © 2018 Willie Johnson. All rights reserved.
//

import SpriteKit

class Player: SKSpriteNode {
  init(position: CGPoint, size: CGSize) {
    super.init(texture: nil, color: Style.PLAYER_COLOR, size: size)
    self.position = position
    self.zPosition = 10
    name = "player"
    
    physicsBody = SKPhysicsBody(rectangleOf: size)
    if let physicsBody = physicsBody {
      physicsBody.affectedByGravity = true
      physicsBody.categoryBitMask = PhysicsCategory.player
      physicsBody.collisionBitMask =
        PhysicsCategory.ground |
        PhysicsCategory.enemy |
        PhysicsCategory.obstacles

      physicsBody.contactTestBitMask =
        PhysicsCategory.ground |
        PhysicsCategory.enemy |
        PhysicsCategory.obstacles
      physicsBody.usesPreciseCollisionDetection = true
    }
    self.addGlow()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func shoot(at direction: CGVector) {
    guard let scene = scene else { return }
    guard let physicsBody = physicsBody else { return }

    let projectilePosition = CGPoint(x: position.x, y: position.y)
    let projectile = Projectile(position: projectilePosition, size: 50)
    scene.addChild(projectile)
    projectile.startDecay()
    projectile.physicsBody!.usesPreciseCollisionDetection = true
    projectile.physicsBody!.applyImpulse(CGVector(dx: (direction.dx * projectile.initialSpeed) + (physicsBody.velocity.dx * 0.15), dy: direction.dy * projectile.initialSpeed))
  }
}

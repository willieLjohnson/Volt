//
//  Player.swift
//  dashable
//
//  Created by Willie Johnson on 3/8/18.
//  Copyright © 2018 Willie Johnson. All rights reserved.
//

import SpriteKit

class Player: SKSpriteNode {
  var canShoot = true

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
    if !canShoot { return }

    let projectilePosition = CGPoint(x: position.x, y: position.y)
    let projectile = Projectile(position: projectilePosition, size: 40)
    scene.addChild(projectile)
    projectile.startDecay()
    if let projectileBody = projectile.physicsBody {
      projectileBody.usesPreciseCollisionDetection = true
      projectileBody.applyImpulse(CGVector(dx: (direction.dx * projectile.initialSpeed) + (physicsBody.velocity.dx * 0.15), dy: direction.dy * projectile.initialSpeed))
      projectileBody.applyAngularImpulse(CGFloat(Int.random(in: -1000..<1000)))

      projectile.zRotation = atan2(projectileBody.velocity.dy, projectileBody.velocity.dx)

    }
    

    canShoot = false

    let command: SKAction = .run {
      self.canShoot = true
    }

    let wait: SKAction = .wait(forDuration: 0.025)
    let sequence: SKAction = .sequence([wait, command])

    run(sequence)
  }
}

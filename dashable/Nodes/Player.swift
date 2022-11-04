//
//  Player.swift
//  dashable
//
//  Created by Willie Johnson on 3/8/18.
//  Copyright © 2018 Willie Johnson. All rights reserved.
//

import SpriteKit

class Player: SKSpriteNode {
  var health: Int = 1000
  var canEvolve: Bool = false
  var canShoot = true
  var jumpDensity: CGFloat = 10
  var jumpMoveSpeed: CGFloat = 20
  var defaultDensity: CGFloat = 1
  var defaultMoveSpeed: CGFloat = 2
  var moveSpeed: CGFloat = 2
  var isBoosting: Bool = false
  var isJumping: Bool = false
  var justJumped: Bool = false

  required init(position: CGPoint, size: CGSize, color: SKColor = Style.PLAYER_COLOR, categoryMask: UInt32 = PhysicsCategory.player) {
    super.init(texture: nil, color: color, size: size)
    self.position = position
    self.zPosition = 10
    name = GameConstants.PlayerName
    
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
      physicsBody.affectedByGravity = false
    }
    self.addGlow()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func jump() {
    if isJumping { return }
    guard let physicsBody = physicsBody else { return }

    isJumping = true
    justJumped = true
    physicsBody.density = jumpDensity
    moveSpeed = jumpMoveSpeed
    physicsBody.applyImpulse(CGVector(dx: 0, dy: 800))
  }

  func shoot(at direction: CGVector, scene: GameScene) {
    guard let physicsBody = physicsBody else { return }
    if !canShoot { return }

    let projectilePosition = CGPoint(x: position.x, y: position.y)
    let projectile = Projectile(position: projectilePosition, size: 40)
    scene.addChild(projectile)

    projectile.startDecay()
    if let projectileBody = projectile.physicsBody {
      projectileBody.usesPreciseCollisionDetection = true
      projectileBody.velocity = physicsBody.velocity
      projectileBody.applyImpulse(CGVector(dx: (direction.dx * projectile.initialSpeed), dy: direction.dy * projectile.initialSpeed))
      
      projectile.zRotation = atan2(projectileBody.velocity.dy, projectileBody.velocity.dx)
    }

    canShoot = false

    let command: SKAction = .run {
      self.canShoot = true
    }

    let wait: SKAction = .wait(forDuration: 0.015)
    let sequence: SKAction = .sequence([wait, command])

    run(sequence)
  }
}

extension Player: Entity {
  func move(velocity: CGVector) {
    return
  }

  func update(_ scene: GameScene) {
    if !isJumping && justJumped {
      physicsBody!.density = defaultDensity
      moveSpeed = defaultMoveSpeed
      justJumped = false
    }
  }

  func onContact(with: SKNode) {
    return
  }
}

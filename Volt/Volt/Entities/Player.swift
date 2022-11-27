//
//  Player.swift
//  Volt
//
//  Created by Willie Johnson on 3/8/18.
//  Copyright © 2018 Willie Johnson. All rights reserved.
//

import SpriteKit

class Player: Entity {
  var health: Int = 1000
  var canEvolve: Bool = false
  var canShoot = true
  var jumpDensity: CGFloat = 10
  var jumpMoveSpeed: CGFloat = 20
  var defaultDensity: CGFloat = 1
  var defaultMoveSpeed: CGFloat = 6
  var moveSpeed: CGFloat = 10
  var isBoosting: Bool = false
  var isJumping: Bool = false
  var justJumped: Bool = false
  
  private var canPlayShootSound: Bool = true

  required init(size: CGSize, color: SKColor = Theme.player, categoryMask: UInt32 = PhysicsCategory.player) {
    let shapeNode = SKShapeNode(rectOf: size)
    shapeNode.fillColor = color
    
    super.init(texture: shapeNode.fillTexture, color: color, size: size)
    self.zPosition = 10
    name = GameConstants.PlayerName
    
    physicsBody = SKPhysicsBody(rectangleOf: size)
    if let physicsBody = physicsBody {
      physicsBody.affectedByGravity = false
      physicsBody.categoryBitMask = PhysicsCategory.player
      physicsBody.collisionBitMask =
        PhysicsCategory.world |
        PhysicsCategory.enemy |
        PhysicsCategory.obstacles

      physicsBody.contactTestBitMask =
        PhysicsCategory.world |
        PhysicsCategory.enemy |
        PhysicsCategory.obstacles
      physicsBody.usesPreciseCollisionDetection = true
      physicsBody.affectedByGravity = false
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func dash(_ dir: CGVector) {
    MoveComponent.component(from: self).dash(dir: dir)
  }

  func shoot(at direction: CGVector) {
    let projectilePosition = CGPoint(x: position.x, y: position.y)
    if !canShoot { return }
    guard let physicsBody = physicsBody else { return }
    
    let projectile = Projectile(position: projectilePosition, size: 3)
    self.game?.addChild(projectile)
    projectile.startDecay()
    if let projectileBody = projectile.physicsBody {
      projectileBody.usesPreciseCollisionDetection = true
      projectileBody.velocity = physicsBody.velocity
      projectileBody.applyImpulse(CGVector(dx: (direction.dx * projectile.initialSpeed), dy: direction.dy * projectile.initialSpeed))
      projectile.zRotation = CGFloat.random(in: -1...1)
      physicsBody.applyImpulse(-direction * projectile.initialSpeed * 0.001)
    }
    self.canShoot = false
    let fireRateAction = SKAction.sequence([.wait(forDuration: 0.2), .run { [weak self] in
      self?.canShoot = true
    }])
    self.run(fireRateAction)
    
    if self.canPlayShootSound {
      GameWorld.global.playAudio(GameConstants.shootSounds.LazerFileName, duration: 1, volume: 0.1, volumeChangeSpeed: 0.1)
      let audioRateAction = SKAction.sequence([.wait(forDuration: 0.05), .run { [weak self] in
        self?.canPlayShootSound = true
      }])
      self.run(audioRateAction)
    }
    
    //    self.circleWaveMedium(-direction)
    //    self.circleWaveHuge()
  }
}

extension Player {
  func move(velocity: CGVector) {
    return
  }

  func update(_ scene: GameScene, deltaTime: TimeInterval) {
    super.update(deltaTime)
  }

  func onContact(with: SKNode) {
    return
  }
}

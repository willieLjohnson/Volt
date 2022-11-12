//
//  Player.swift
//  dashable
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

  required init(size: CGSize, color: SKColor = Style.PLAYER_COLOR, categoryMask: UInt32 = PhysicsCategory.player) {
    let shapeNode = SKShapeNode(rectOf: size)
    shapeNode.fillColor = color
    
    super.init(texture: shapeNode.fillTexture, color: color, size: size)
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
    let projectile = Projectile(position: projectilePosition, size: 60)
    scene.addChild(projectile)

    projectile.startDecay()
    if let projectileBody = projectile.physicsBody {
      projectileBody.usesPreciseCollisionDetection = true
      projectileBody.velocity = physicsBody.velocity
      projectileBody.applyImpulse(CGVector(dx: (direction.dx * projectile.initialSpeed), dy: direction.dy * projectile.initialSpeed))
      projectile.zRotation = CGFloat.random(in: -1...1)
    }
    canShoot = false
    let fireRateAction = SKAction.sequence([.wait(forDuration: 0.1), .run { [unowned self] in
      self.canShoot = true
    }])
    run(fireRateAction)

    if canPlayShootSound {
      GameWorld.global.playAudio(GameConstants.shootSounds.LazerFileName, duration: 1, volume: 0.01, volumeChangeSpeed: 0.2)
      let audioRateAction = SKAction.sequence([.wait(forDuration: 0.05), .run { [unowned self] in
        self.canPlayShootSound = true
      }])
      self.run(audioRateAction)
    }

    self.circleWaveMedium(-direction)
    self.circleWaveHuge()
  }
}

extension Player {
  func move(velocity: CGVector) {
    return
  }

  func update(_ scene: GameScene, deltaTime: TimeInterval) {
    super.update(deltaTime: deltaTime)
    
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

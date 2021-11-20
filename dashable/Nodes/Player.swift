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
      physicsBody.collisionBitMask = PhysicsCategory.ground | PhysicsCategory.enemy | PhysicsCategory.obstacles
      physicsBody.contactTestBitMask = PhysicsCategory.ground | PhysicsCategory.enemy | PhysicsCategory.sleeper
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
    let obstacleSize = CGSize(width: 50, height: 50)
    let obstaclePosition = CGPoint(x: position.x, y: position.y)

    let categoryMask = PhysicsCategory.projectile
    let collisionMask = PhysicsCategory.ground | PhysicsCategory.enemy | PhysicsCategory.obstacles
    let contactMask = PhysicsCategory.enemy

    let projectile = Obstacle(position: obstaclePosition, size: obstacleSize, categoryMask: categoryMask, collisionMask: collisionMask, contactMask: contactMask)
    projectile.color = Style.PROJECTILE_COLOR
    projectile.physicsBody?.density = 0.45

    let fade = SKAction.fadeAlpha(to: 0, duration: 1)
    projectile.run(fade, completion: { projectile.removeFromParent() })
    scene.addChild(projectile)

    let speed: CGFloat = 2


    projectile.physicsBody!.usesPreciseCollisionDetection = true
    projectile.physicsBody!.applyImpulse(CGVector(dx: direction.dx * speed * physicsBody.velocity.normalized().dx, dy: direction.dy  * speed))
  }
}

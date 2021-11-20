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
      physicsBody.collisionBitMask = PhysicsCategory.ground | PhysicsCategory.player
      physicsBody.contactTestBitMask = PhysicsCategory.ground | PhysicsCategory.player | PhysicsCategory.sleeper
      physicsBody.usesPreciseCollisionDetection = true
    }
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

    let obstacle = Obstacle(position: obstaclePosition, size: obstacleSize, categoryMask: categoryMask, collisionMask: collisionMask, contactMask: contactMask)
    obstacle.color = Style.PROJECTILE_COLOR
    scene.addChild(obstacle)

    let speed: CGFloat = 5
    obstacle.physicsBody!.usesPreciseCollisionDetection = true
    obstacle.physicsBody!.applyImpulse(CGVector(dx: direction.dx * speed, dy: direction.dy  * speed))
  }
}

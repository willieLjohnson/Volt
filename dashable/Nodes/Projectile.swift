//
//  Projectile.swift
//  Projectile
//
//  Created by Willie Johnson on 11/20/21.
//  Copyright © 2021 Willie Johnson. All rights reserved.
//

import Foundation

import SpriteKit

class Projectile: SKSpriteNode {
  let initialSpeed: CGFloat = 4

  init(position: CGPoint, size: CGFloat, color: SKColor = Style.PROJECTILE_COLOR) {
    super.init(texture: nil, color: Style.OBSTACLE_COLOR, size: CGSize(width: size, height: size))
    self.position = position
    self.color = color

    name = "projectile"
    physicsBody = SKPhysicsBody(circleOfRadius: size)

    guard let physicsBody = physicsBody else { return }
    physicsBody.density = 0.4
    physicsBody.affectedByGravity = false
    physicsBody.isDynamic = true
    physicsBody.categoryBitMask = PhysicsCategory.projectile
    physicsBody.collisionBitMask = PhysicsCategory.enemy | PhysicsCategory.ground | PhysicsCategory.obstacles
    physicsBody.contactTestBitMask = PhysicsCategory.enemy | PhysicsCategory.obstacles
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func startDecay() {
    let fade = SKAction.fadeAlpha(to: 0, duration: 2)
    let scale = SKAction.scale(to: 0, duration: 2)
    run(scale)
    run(fade, completion: { self.removeFromParent() })
  }
}

//
//  Obstacle.swift
//  dashable
//
//  Created by Willie Johnson on 3/15/18.
//  Copyright © 2018 Willie Johnson. All rights reserved.
//

import SpriteKit

class Obstacle: SKSpriteNode {
  
  init(position: CGPoint, size: CGSize, isDynamic: Bool = true, categoryMask: UInt32 = PhysicsCategory.obstacles, collisionMask: UInt32, contactMask: UInt32) {
    super.init(texture: nil, color: #colorLiteral(red: 0.9882352941, green: 0.4941176471, blue: 0, alpha: 1), size: size)
    self.position = position
    self.zPosition = 10
    name = "obstacle"

    physicsBody = SKPhysicsBody(rectangleOf: size)

    guard let physicsBody = physicsBody else { return }
    physicsBody.affectedByGravity = true
    physicsBody.isDynamic = isDynamic
    physicsBody.categoryBitMask = categoryMask
    physicsBody.collisionBitMask = collisionMask
    physicsBody.contactTestBitMask = contactMask
  }

  convenience init(position: CGPoint, size: CGSize, isDynamic: Bool = true) {
    let collisionMask = PhysicsCategory.ground | PhysicsCategory.player | PhysicsCategory.obstacles
    let contactMask = PhysicsCategory.player
    self.init(position: position, size: size, isDynamic: isDynamic, collisionMask: collisionMask, contactMask: contactMask)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

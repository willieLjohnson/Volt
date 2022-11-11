//
//  Ground.swift
//  dashable
//
//  Created by Willie Johnson on 3/8/18.
//  Copyright © 2018 Willie Johnson. All rights reserved.
//

import SpriteKit

class Ground: SKSpriteNode {
  init(position: CGPoint, size: CGSize) {
    super.init(texture: nil, color: Style.GROUND_COLOR, size: size)
    self.zPosition = 10
    name = "ground"
    
    self.position = position
    physicsBody = SKPhysicsBody(rectangleOf: size)
    if let physicsBody = physicsBody {
      physicsBody.affectedByGravity = false
      physicsBody.isDynamic = false
      physicsBody.categoryBitMask = PhysicsCategory.ground
      physicsBody.collisionBitMask =
        PhysicsCategory.player |
        PhysicsCategory.enemy |
        PhysicsCategory.projectile |
        PhysicsCategory.obstacles
    }
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

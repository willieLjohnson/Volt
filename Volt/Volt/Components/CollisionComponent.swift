//
//  CollisionComponent.swift
//  Volt
//
//  Created by Willie Liwa Johnson on 11/8/22.
//  Copyright © 2022 Willie Johnson. All rights reserved.
//

import Foundation
import SpriteKit

typealias EntityHandler = (Entity?) -> ()
class CollisionComponent: Component {
  var collisionHandler: EntityHandler?
  var contactHandler: EntityHandler?
  var physicsBody: SKPhysicsBody {
    entity!.physicsBody!
  }
  
  init(entity: Entity, category: UInt32 = PhysicsCategory.none, density: CGFloat = 1, collisionMask: UInt32 = 0, contactMask: UInt32 = 0) {
    super.init(entity: entity)
    self.entity = entity
    entity.physicsBody = SKPhysicsBody(rectangleOf: entity.size)
    if let physicsBody = entity.physicsBody {
      physicsBody.density = density
      physicsBody.allowsRotation = true
      physicsBody.isDynamic = true
      physicsBody.affectedByGravity = false
      physicsBody.categoryBitMask = category
      physicsBody.collisionBitMask = collisionMask
      physicsBody.contactTestBitMask = contactMask
      physicsBody.usesPreciseCollisionDetection = true
    }
  }
  
  func onContact(with other: Entity) {
    guard let contactHandler = contactHandler else { return }
    contactHandler(other)
  }
  
  func onCollision(with other: Entity) {
    guard let collisionHandler = collisionHandler else { return }
    collisionHandler(other)
  }
}

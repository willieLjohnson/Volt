//
//  LocusComponent.swift
//  Volt
//
//  Created by Willie Liwa Johnson on 11/10/22.
//  Copyright © 2022 Willie Johnson. All rights reserved.
//

import Foundation

class LocusComponent: Component {
  var targetFirstPosition: CGPoint = .zero
  var targetLastPosition: CGPoint = .zero
  
  var maxDistance: CGFloat {
    minDistance + 100
  }
  var minDistance: CGFloat {
    guard let entity = self.entity else { return 0 }
    return (entity.size.width + entity.size.height)
  }
  
  var midDistance: CGFloat {
    (maxDistance + minDistance) / 2
  }
  
  var target: Entity? {
    willSet {
      guard newValue != nil else { return }
      targetFirstPosition = newValue!.position
    }
    didSet {
      guard target != nil else { return }
      targetFirstPosition = target!.position
    }
  }
  
  var distance: CGFloat {
    guard let target = self.target else { return .zero }
    guard let entity = self.entity else { return .zero }
    return entity.position.distance(to: target.position)
  }
  
  var difference: CGPoint {
    guard let target = self.target else { return .zero }
    guard let entity = self.entity else { return .zero }
    return entity.position - target.position
  }
  
  var velocityDifference: CGVector {
    guard let target = self.target, let entity = self.entity else { return .zero }
    guard let targetPhysicsBody = target.physicsBody, let entityPhysicsBody = entity.physicsBody else { return .zero }
    return entityPhysicsBody.velocity - targetPhysicsBody.velocity
  }
  
  var speedDifference: CGFloat {
    guard let target = self.target, let entity = self.entity else { return .zero }
    guard let targetPhysicsBody = target.physicsBody, let entityPhysicsBody = entity.physicsBody else { return .zero }
    return entityPhysicsBody.velocity.distance(to: targetPhysicsBody.velocity)
  }
  
  var targetInAttackRange: Bool {
    guard self.target != nil else { return false }
    guard let entity = self.entity else { return false }
    guard let weaponComponent = entity.component(ofType: WeaponComponent.self) as? WeaponComponent else { return false }
    return distance <= weaponComponent.attackRange + entity.size.height
  }
  
  var targetIsAttackable: Bool {
    targetInAttackRange && !targetFaster
  }
  
  var targetTooClose: Bool {
    distance < minDistance
  }
  var targetNear: Bool {
    distance >= minDistance && distance < midDistance
  }
  
  var targetFar: Bool {
    distance >= midDistance && distance < maxDistance
  }
  
  var targetVeryFar: Bool {
    distance >= maxDistance && distance <= maxDistance * 2
  }
  
  var targetTooFar: Bool {
    distance > maxDistance * 2
  }
  
  var targetAhead: Bool {
    distance.magnitude > 0 && areMovingInTheSameDirection
  }
  
  var areMovingInTheSameDirection: Bool {
    guard let target = self.target, let entity = self.entity else { return false }
    guard let targetPhysicsBody = target.physicsBody, let entityphysicsBody = entity.physicsBody else { return false }
    var dotProd = targetPhysicsBody.velocity.dot(entityphysicsBody.velocity)
    return dotProd > 0 || dotProd < 0
  }
  
  var targetFaster: Bool {
    speedDifference > 100
  }

  init(entity: Entity? = nil, target: Entity?) {
    self.target = target
    super.init(entity: entity)
  }
  
  override func update(_ deltaTime: TimeInterval?) {
    guard let target = target else { return }
    targetLastPosition = target.position
  }
}

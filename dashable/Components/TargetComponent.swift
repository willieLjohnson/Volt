//
//  TargetComponent.swift
//  dashable
//
//  Created by Willie Liwa Johnson on 11/10/22.
//  Copyright © 2022 Willie Johnson. All rights reserved.
//

import Foundation

class TargetComponent: Component {
  var maxDistance: CGFloat = 10000
  var minDistance: CGFloat = 500
  
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
  var targetFirstPosition: CGPoint = .zero
  var targetLastPosition: CGPoint = .zero
  
  var distanceFromTarget: CGFloat {
    guard let target = self.target else { return .zero }
    guard let entity = self.entity else { return .zero }
    return target.position.distance(to: entity.position)
  }
  
  var isInAttackRange: Bool {
    guard self.target != nil else { return false }
    guard let entity = self.entity else { return false }
    guard let weaponComponent = entity.component(ofType: WeaponComponent.self) as? WeaponComponent else { return false }
    return distanceFromTarget <= weaponComponent.attackRange
  }
  
  var isTooClose: Bool {
    guard self.target != nil else { return false }
    guard self.entity != nil else { return false }
    return distanceFromTarget <= minDistance
  }
  var isNearTarget: Bool {
    guard self.target != nil else { return false }
    guard self.entity != nil else { return false }
    return isInAttackRange && !isTooClose
  }
  
  var isFarFromtarget: Bool {
    guard self.target != nil else { return false }
    guard self.entity != nil else { return false }
    return !isInAttackRange && distanceFromTarget <= maxDistance
  }
  var isVeryFar: Bool {
    guard self.target != nil else { return false }
    guard self.entity != nil else { return false }
    return distanceFromTarget > maxDistance
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

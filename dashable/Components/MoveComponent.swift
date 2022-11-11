//
//  MoveComponent.swift
//  dashable
//
//  Created by Willie Johnson on 3/17/18.
//  Copyright © 2018 Willie Johnson. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class MoveComponent: Component {
  private var baseMoveSpeed: CGFloat = 1.0
  var moveSpeed: CGFloat = 1.0
  
  init(entity: Entity? = nil, moveSpeed: CGFloat = 1.0) {
    super.init(entity: entity)
    self.moveSpeed = moveSpeed
    self.baseMoveSpeed = moveSpeed
  }
  
  func follow(other: Entity) {
    self.impulseTowards(point: other.position)
  }
  
  func move(dir: CGVector) {
    self.impulse(velocity: dir * self.moveSpeed)
  }
  
  func impulse(velocity: CGVector) {
    guard let entity = self.entity else { return }
    guard let physicsBody = entity.physicsBody else { return }
    physicsBody.applyImpulse(velocity)
  }
  
  func match(velocity: CGVector) {
    guard let entity = self.entity else { return }
    guard let physicsBody = entity.physicsBody else { return }
    physicsBody.velocity = velocity
  }
  
  func impulseTowards(point: CGPoint) {
    guard let entity = self.entity else { return }
    let dir = point.difference(with: entity.position).direction
    self.move(dir: CGVector(dx: dir.x, dy: dir.y))
  }
  
  func getBaseMoveSpeed() -> CGFloat {
    return baseMoveSpeed
  }
  
  func setBase(moveSpeed: CGFloat) {
    self.baseMoveSpeed = moveSpeed
    self.moveSpeed = moveSpeed
  }
}

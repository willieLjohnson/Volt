//
//  MoveComponent.swift
//  Volt
//
//  Created by Willie Johnson on 3/17/18.
//  Copyright © 2018 Willie Johnson. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

struct MoveStats {
  var velocity: CGVector = .zero
  var moveSpeed: CGFloat = 0
  var isMoving: Bool = false
  var maxSpeed: CGFloat = 0
  var baseMoveSpeed: CGFloat = 0
}

class MoveComponent: Component {
  private var baseMoveSpeed: CGFloat = 0.01
  var moveSpeed: CGFloat = 0.01
  var maxSpeed: CGFloat = 1
  var physicsBody: SKPhysicsBody {
    guard let entity = self.entity,
      let physicsBody = entity.physicsBody else { return SKPhysicsBody() }
    return physicsBody
  }
  var previousStats = MoveStats()
  var momentum: CGVector {
    physicsBody.velocity * 0.01
  }
  
  var isMoving: Bool {
    guard let entity = self.entity else { return false }
    guard let physicsBody = entity.physicsBody else { return false }
    return physicsBody.velocity.magnitude > 0
  }
  
  init(entity: Entity? = nil, moveSpeed: CGFloat = 0.01) {
    super.init(entity: entity)
    self.moveSpeed = moveSpeed
    self.baseMoveSpeed = moveSpeed
    self.previousStats = getStats()
  }
  
  override func update(_ deltaTime: TimeInterval?) {
    previousStats = getStats()
    super.update(deltaTime)
  }
  
  func boost(amount: CGFloat) {
    self.moveSpeed += amount
  }
  
  func boost(by amount: CGFloat) {
    self.moveSpeed = self.getBaseMoveSpeed() * amount
  }
  
  func accelerate(speed: CGFloat) {
    self.moveSpeed += speed
  }
  
  func decelerate(speed: CGFloat) {
    self.moveSpeed -= speed
    if self.moveSpeed < self.getBaseMoveSpeed() {
      self.moveSpeed = self.getBaseMoveSpeed()
    }
  }
  
  func brake(effeciency: CGFloat = 10) {
    guard let entity = entity else { return }
    guard let physicsBody = entity.physicsBody else { return }
    physicsBody.velocity *= 0.99 / effeciency
  }
  
  func dashTo(other: Entity) {
    self.impulseTowards(point: other.position)
  }
  
  func follow(other: Entity) {
    guard self.entity != nil else { return }
    self.forceTowards(point: other.position)
  }
  
  
  func flee(other: Entity) {
    self.impulseAway(point: other.position)
  }
  
  func dash(dir: CGVector) {
    self.impulse(velocity: dir * self.moveSpeed)
  }
  
  func move(dir: CGVector) {
    self.force(velocity: dir * self.moveSpeed)
  }
  
  func force(velocity: CGVector) {
    guard let entity = self.entity else { return }
    guard let physicsBody = entity.physicsBody else { return }
    physicsBody.applyForce(velocity)
  }
  
  func impulse(velocity: CGVector) {
    guard let entity = self.entity else { return }
    guard let physicsBody = entity.physicsBody else { return }
    physicsBody.applyImpulse(velocity)
  }
  
  func set(velocity: CGVector) {
    guard let entity = self.entity else { return }
    guard let physicsBody = entity.physicsBody else { return }
    physicsBody.velocity = velocity
  }
  
  func match(velocity: CGVector) {
    guard let entity = self.entity else { return }
    guard let physicsBody = entity.physicsBody else { return }
    physicsBody.velocity = physicsBody.velocity.lerp(start: physicsBody.velocity, end: velocity, t: 0.7)
  }
  func impulseTowards(point: CGPoint) {
    guard let entity = self.entity else { return }
    self.dash(dir: CGVector(entity.position.direction(to: point)))
  }
  
  func forceTowards(point: CGPoint) {
    guard let entity = self.entity else { return }
    self.move(dir: CGVector(entity.position.direction(to: point)))
  }
  
  func impulseAway(point: CGPoint) {
    guard let entity = self.entity else { return }
    self.dash(dir: -CGVector(entity.position.direction(to: point)))
  }
  
  
  func getBaseMoveSpeed() -> CGFloat {
    return baseMoveSpeed
  }
  
  func setBase(moveSpeed: CGFloat) {
    self.baseMoveSpeed = moveSpeed
    self.moveSpeed = moveSpeed
  }
  
  func getStats() -> MoveStats {
    return MoveStats(velocity: physicsBody.velocity, moveSpeed: moveSpeed, isMoving: isMoving, maxSpeed: maxSpeed, baseMoveSpeed: baseMoveSpeed)
  }
}

//
//  ChaseAction.swift
//  dashable
//
//  Created by Willie Liwa Johnson on 11/12/22.
//  Copyright © 2022 Willie Johnson. All rights reserved.
//

import Foundation

enum MovementType {
  case Impulse
  case Force
  case Match(CGFloat)
  case Flee
}

class Chasing: EnemyAction {
  var movementType: MovementType = .Impulse
  
  var moveComponent: MoveComponent {
    MoveComponent.component(from: agent!)
  }
  var targetComponent: TargetComponent {
    TargetComponent.component(from: agent!)
  }
  
  var healthComponent: HealthComponent {
    HealthComponent.component(from: agent!)
  }
  
  var target: Entity? {
    targetComponent.target
  }
  
  init(agent: Enemy, movementType: MovementType = .Impulse) {
    super.init(agent: agent)
    self.movementType = movementType
    healthComponent.subscribe(uuid: agent.id) {
      if Int.random(in: 0...100) > 20  {
        self.flee()
      }
    }
  }
  func from(_ transition: Transition) -> Result {
    self.start()
    agent?.run(.sequence([.scale(to: 0.5, duration: 0.01), .scale(to: 1, duration: 0.1)])) {[unowned self] in
      self.done(.Completed)
    }
    return .Init
  }
  
  override func update(_ deltaTime: TimeInterval?) {
    super.update(deltaTime)
    guard let target = target else { return done(.Failed("No target")) }
    guard let agent = agent else { return done(.Failed("No agent"))}
    
    let angle = atan2(target.position.y - agent.position.y , target.position.x -
                      agent.position.x)
    agent.zRotation = (angle - CGFloat(Double.pi/2))
    chase()
  }
  
  func chase() {
    switch movementType {
    case .Impulse:
      rush()
    case .Force:
      follow()
    case .Flee:
      flee()
    case .Match(let factor):
      shadow(factor)
    }
  }
  
  func shadow(_ factor: CGFloat) {
    guard let target = target else { return done(.Failed("No target")) }
    moveComponent.match(velocity: target.physicsBody!.velocity * factor)
  }
  
  func rush() {
    guard let target = target else { return done(.Failed("No target")) }
    moveComponent.impulseTowards(point: target.position)
  }
  
  func follow() {
    guard let target = target else { return done(.Failed("No target")) }
    moveComponent.forceTowards(point: target.position)
  }
  
  func flee() {
    guard let target = target else { return done(.Failed("No target")) }
    moveComponent.flee(other: target)
  }
}

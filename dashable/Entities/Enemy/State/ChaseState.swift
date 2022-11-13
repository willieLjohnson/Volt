//
//  ChaseState.swift
//  dashable
//
//  Created by Willie Liwa Johnson on 11/10/22.
//  Copyright © 2022 Willie Johnson. All rights reserved.
//

import Foundation
import GameplayKit

class ChaseState: EnemyState {
  override func isValidNextState(_ stateClass: AnyClass) -> Bool {
    return true
  }
  
  override func didEnter(from previousState: GKState?) {
    self.actions = [
      Chasing(enemy: self.enemy, didInit: { action,enemy in
        enemy.run(.scale(to: 1, duration: 0.1))
      })
    ]
    self.execute(Chasing.self)
  }
  
  override func update(deltaTime seconds: TimeInterval) {
    guard let stateMachine = self.stateMachine as? EnemyLogic else { return }
    if let logicHandler = logicHandler  {
      logicHandler(stateMachine, enemy)
    } else {
      guard let moveComponent = self.enemy.component(ofType: MoveComponent.self) as? MoveComponent else {return}
      guard let targetComponent = self.enemy.component(ofType: TargetComponent.self) as? TargetComponent else {return}
      guard let target = targetComponent.target else { return }
      moveComponent.follow(other: target)
    }
  }
}

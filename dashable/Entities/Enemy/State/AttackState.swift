//
//  AttackState.swift
//  dashable
//
//  Created by Willie Liwa Johnson on 11/10/22.
//  Copyright © 2022 Willie Johnson. All rights reserved.
//

import Foundation
import GameplayKit

class AttackState: EnemyState {
  override func isValidNextState(_ stateClass: AnyClass) -> Bool {
    switch stateClass {
    default:
      return true
    }
  }
  
  override func update(deltaTime seconds: TimeInterval) {
    guard let currentAction = currentAction else { return }
    currentAction.update(seconds)
    guard let stateMachine = self.stateMachine else { return }
    switch currentAction.status {
    case .Init:
      break;
    case .Running:
      break;
    default:
      stateMachine.enter(ChaseState.self)
    }
  }
  
  override func didEnter(from previousState: GKState?) {
    self.actions = [
      EnemyAttacking(enemy: self.enemy, updateHandler: { action, enemy in
        enemy.run(.scale(to: 10, duration: 0.1)) {
          action.status = .Success
        }
      }),
    ]
    self.execute(EnemyAttacking.self)
  }
}

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

  override func didEnter(from previousState: GKState?) {
    enemy.run(.scale(to: 10, duration: 0.1) ) {
      guard let stateMachine = self.stateMachine else { return }
      stateMachine.enter(ChaseState.self)
    }
  }
}

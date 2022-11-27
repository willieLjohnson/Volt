//
//  AttackAction.swift
//  Volt
//
//  Created by Willie Liwa Johnson on 11/12/22.
//  Copyright © 2022 Willie Johnson. All rights reserved.
//

import Foundation

class Attacking: EnemyAction {
  func from(_ transition: Transition) -> Result {
    switch type(of: transition) {
    case is CombatState.Type:
      self.agent?.run(.scale(to: 2, duration: 0.1)) { [unowned self] in
        // moveComponent.set(velocity: physicsBody.velocity * 2)
        self.done(.Completed)
      }
      return .Init
    default:
      return .Init
    }
  }
}

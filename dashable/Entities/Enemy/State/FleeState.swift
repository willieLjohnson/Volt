//
//  RunState.swift
//  dashable
//
//  Created by Willie Liwa Johnson on 11/10/22.
//  Copyright © 2022 Willie Johnson. All rights reserved.
//

import Foundation
import GameplayKit

class FleeState: EnemyAction {
  func can(transtionTo transition: Transition.Type) -> Bool {
    switch transition {
    case is CombatState.Type:
      return false
    default:
      return true
    }
  }
  
  func update(deltaTime seconds: TimeInterval) {
    guard let moveComponent = self.agent?.component(ofType: MoveComponent.self) as? MoveComponent else {return}
    guard let targetComponent = self.agent?.component(ofType: TargetComponent.self) as? TargetComponent else {return}
    guard let target = targetComponent.target else { return }
    moveComponent.flee(other: target)
  }
}


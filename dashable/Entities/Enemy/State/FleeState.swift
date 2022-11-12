//
//  RunState.swift
//  dashable
//
//  Created by Willie Liwa Johnson on 11/10/22.
//  Copyright © 2022 Willie Johnson. All rights reserved.
//

import Foundation
import GameplayKit

class FleeState: EnemyState {
  override func isValidNextState(_ stateClass: AnyClass) -> Bool {
    switch stateClass {
    case is AttackState.Type:
      return false
    default:
      return true
    }
  }
  
  
  override func update(deltaTime seconds: TimeInterval) {
    guard let moveComponent = self.enemy.component(ofType: MoveComponent.self) as? MoveComponent else {return}
    guard let targetComponent = self.enemy.component(ofType: TargetComponent.self) as? TargetComponent else {return}
    guard let target = targetComponent.target else { return }
    moveComponent.flee(other: target)
    
  }
  
}


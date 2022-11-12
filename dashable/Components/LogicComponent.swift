//
//   LogicComponent.swift
//  dashable
//
//  Created by Willie Liwa Johnson on 11/8/22.
//  Copyright © 2022 Willie Johnson. All rights reserved.
//

import Foundation
import GameplayKit

class LogicComponent: Component {
  var logic: Logic?
  var currentState: GKState? {
    guard let logic = logic else { return nil }
    return logic.currentState
  }

  var disabled: Bool = false
  
  init(entity: Entity? = nil, logic: Logic? = nil, enter state: AnyClass? = nil) {
    self.logic = logic
    super.init(entity: entity)
    if state != nil {
      self.enter(state!)
    }
  }
  
  func enter(_ state: AnyClass) {
    guard let logic = logic else { return }
    logic.enter(state)
  }
  
  override func update(_ deltaTime: TimeInterval?) {
    guard let logic = logic else { return }
    if disabled { return }
    logic.update(deltaTime: deltaTime!)
  }
}


//
//   LogicComponent.swift
//  dashable
//
//  Created by Willie Liwa Johnson on 11/8/22.
//  Copyright © 2022 Willie Johnson. All rights reserved.
//

import Foundation
import GameplayKit

class ActionComponent<AgentType: Agent>: Component {
  var machine: ActionMachine<AgentType>?
  var currentAction: Action<AgentType>? {
    machine?.currentAction
  }

  var disabled: Bool = false
  
  init(entity: Entity? = nil, machine: ActionMachine<AgentType>? = nil) {
    super.init(entity: entity)
    self.machine = machine
  }
  
  func execute(_ actionClass: Action<AgentType>.Type) -> Result {
    self.machine != nil ? self.machine!.execute(actionClass) : .Failed("No action machine")
  }
  
  override func update(_ deltaTime: TimeInterval?) {
    if disabled { return }
    machine?.update(deltaTime)
  }
}


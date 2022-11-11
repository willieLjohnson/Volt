//
//   LogicComponent.swift
//  dashable
//
//  Created by Willie Liwa Johnson on 11/8/22.
//  Copyright © 2022 Willie Johnson. All rights reserved.
//

import Foundation

class LogicComponent: Component {
  let logic: Logic
  var disabled: Bool = false
  
  init(entity: Entity? = nil, logic: Logic) {
    self.logic = logic
    super.init(entity: entity)
  }
  
  override func update(_ deltaTime: TimeInterval?) {
    if disabled { return }
    logic.update(deltaTime!)
  }
}


//
//  EvolveComponent.swift
//  Volt
//
//  Created by Willie Liwa Johnson on 11/8/22.
//  Copyright © 2022 Willie Johnson. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class EvolveComponent: Component {
  var canEvolve: Bool = true
  var hasEvolved: Bool = false
  var onEvolveHandler: EntityHandler?
  
  init(entity: Entity? = nil, canEvolve: Bool = true, onEvolveHandler: EntityHandler? = nil) {
    super.init(entity: entity)
    self.canEvolve = canEvolve
    self.onEvolveHandler = onEvolveHandler
  }
  
  func evolve() {
    guard let entity = self.entity else { return }
    if let onEvolveHandler = onEvolveHandler {
      onEvolveHandler(entity)
    }
  }
}

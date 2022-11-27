//
//  SpriteComponent.swift
//  Volt
//
//  Created by Willie Johnson on 3/16/18.
//  Copyright © 2018 Willie Johnson. All rights reserved.
//

import Foundation
import GameplayKit
import SpriteKit

class HealthComponent: Component {
  var max: Int = 1
  var current: Int = 1 {
    didSet {
      notifySubscribers()
    }
  }
  
  init(entity: Entity, health: Int = 1) {
    super.init(entity: entity)
    self.current = health
    self.max = health
  }
  
  func damage(_ amount: Int = 1) {
    current -= amount
    checkStatus()
  }
  
  override func checkStatus() {
    guard let entity = entity else { return }
    if current <= 0 {
      entity.decompose()
    }
  }
}

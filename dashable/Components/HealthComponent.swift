//
//  SpriteComponent.swift
//  dashable
//
//  Created by Willie Johnson on 3/16/18.
//  Copyright © 2018 Willie Johnson. All rights reserved.
//

import Foundation
import GameplayKit
import SpriteKit

class HealthComponent: Component {
  var health: Int = 1 {
    didSet {
      notifySubscribers()
    }
  }
  
  init(entity: Entity, health: Int = 1) {
    super.init(entity: entity)
    self.health = health
  }
  
  func damage(_ amount: Int = 1) {
    health -= amount
    checkStatus()
  }
  
  override func checkStatus() {
    guard let entity = entity else { return }
    if health <= 0 {
      entity.decompose()
    }
  }
}

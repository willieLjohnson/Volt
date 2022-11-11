//
//  EnemyState.swift
//  dashable
//
//  Created by Willie Liwa Johnson on 11/10/22.
//  Copyright © 2022 Willie Johnson. All rights reserved.
//

import Foundation
import GameplayKit

typealias StateHandler = (GameScene, Set<Entity>) -> ()
typealias LogicHandler = (EnemyState, Entity) -> ()

class EnemyState: GKState {
  let enemy: Enemy
  var logicHandler: LogicHandler? = nil
  
  init(enemy: Enemy, logicHandler: LogicHandler? = nil) {
    self.enemy = enemy
    self.logicHandler = logicHandler
    super.init()
  }
  
  override func update(deltaTime seconds: TimeInterval) {
    logicHandler?(self, enemy)
  }
}

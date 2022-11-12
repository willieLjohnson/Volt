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
typealias LogicHandler = (Logic, Entity) -> ()

class EnemyState: GKState {
  let enemy: Enemy
  var logicHandler: LogicHandler? = nil
  var completionHandler: LogicHandler? = nil
  
  init(enemy: Enemy, logicHandler: LogicHandler? = nil, completionHandler: LogicHandler? = nil) {
    self.enemy = enemy
    self.logicHandler = logicHandler
    super.init()
  }
  
  override func update(deltaTime seconds: TimeInterval) {
    guard let stateMachine = self.stateMachine as? EnemyLogic,
    let logicHandler = logicHandler else { return }
    logicHandler(stateMachine, enemy)
  }
}

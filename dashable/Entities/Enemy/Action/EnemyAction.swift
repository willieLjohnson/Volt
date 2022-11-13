//
//  EnemyAction.swift
//  dashable
//
//  Created by Willie Liwa Johnson on 11/12/22.
//  Copyright © 2022 Willie Johnson. All rights reserved.
//

import Foundation
import GameplayKit

typealias ActionHandler = (EnemyAction, Entity) -> Void
typealias StatusHandler = (Status) -> Void

enum Status {
  case Init
  case Success
  case Running
  case Failed
}

class EnemyAction: Hashable {
  var id: UUID = UUID()
  var enemy: Enemy
  var status: Status = .Init
  var updateHandler: ActionHandler?
  
  init(enemy: Enemy, updateHandler: ActionHandler? = nil) {
    self.enemy = enemy
    self.updateHandler = updateHandler
  }
  
  func update(_ deltaimeTime: TimeInterval) {
    updateHandler?(self, self.enemy)
  }
  
  func start() {
    self.status = .Running
  }
}

extension EnemyAction: Equatable {
  func hash(into hasher: inout Hasher) {
    hasher.combine(enemy)
  }
  
  static func == (lhs: EnemyAction, rhs: EnemyAction) -> Bool {
    lhs.id == rhs.id && rhs.enemy.id == lhs.enemy.id
  }
}

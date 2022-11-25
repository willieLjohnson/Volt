//
//  CombatState.swift
//  dashable
//
//  Created by Willie Liwa Johnson on 11/10/22.
//  Copyright © 2022 Willie Johnson. All rights reserved.
//

import Foundation
import GameplayKit

struct EnemyActions {
  
}

class CombatState: EnemyAction {

  override func from(action: ActionMachine<Enemy>) -> Result {
    return self.execute(Chasing.self)
  }
}

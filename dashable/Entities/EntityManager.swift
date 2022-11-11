//
//  EntityManager.swift
//  dashable
//
//  Created by Willie Johnson on 3/16/18.
//  Copyright © 2018 Willie Johnson. All rights reserved.
//

import Foundation
import GameplayKit
import SpriteKit

class EntityManager {
  var entities = Set<Entity>()
  let game: GameScene

  init(game: GameScene) {
    self.game = game
  }
  func add(entity: Entity) {
    entities.insert(entity)
  }
  
  func remove(entity: Entity) {
    _ = entity.components.map {
      entity.removeComponent(ofType: type(of: $0))
    }
    entities.remove(entity)
  }
  
  func update(deltaTime: TimeInterval) {
    _ = entities.map {
      $0.update(deltaTime: deltaTime)
    }
  }
}

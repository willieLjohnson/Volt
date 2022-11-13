//
//  Component.swift
//  dashable
//
//  Created by Willie Liwa Johnson on 11/8/22.
//  Copyright © 2022 Willie Johnson. All rights reserved.
//

import Foundation


class Component: Hashable {
  var id: UUID = UUID()

  var entity: Entity? = nil
  var game: GameScene? = nil
  init(entity: Entity? = nil) {
    self.entity = entity
    self.game = entity?.game
  }
  func checkStatus() {}
  func update(_ deltaTime: TimeInterval?) {}
  
  static func component(from entity: Entity) -> Self {
    entity.component(ofType: Self.self) as! Self
  }
}

// MARK: - Hashable
extension Component {
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
    hasher.combine(entity)
  }
  static func == (lhs: Component, rhs: Component) -> Bool {
    lhs.id == rhs.id
  }
}

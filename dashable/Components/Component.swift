//
//  Component.swift
//  dashable
//
//  Created by Willie Liwa Johnson on 11/8/22.
//  Copyright © 2022 Willie Johnson. All rights reserved.
//

import Foundation

typealias EntityHandler = (Entity) -> ()

class Component {
  var entity: Entity?
  var game: GameScene? {
    self.entity?.game
  }
  init(entity: Entity? = nil) {
    self.entity = entity
  }
  func checkStatus() {}
  func update(_ deltaTime: TimeInterval?) {}
  
  static func component(from entity: Entity) -> Self {
    entity.component(ofType: Self.self) as! Self
  }
}

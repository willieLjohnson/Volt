//
//  Component.swift
//  dashable
//
//  Created by Willie Liwa Johnson on 11/8/22.
//  Copyright © 2022 Willie Johnson. All rights reserved.
//

import Foundation


  
protocol Subscribable: Updatable {
  var subscribers: [UUID: [()->()]] { get set }
  mutating func subscribe(uuid: UUID, onUpdate: @escaping ()->())
  mutating func notifySubscribers()
}

class Component: Subscribable {
  var id: UUID = UUID()
  var entity: Entity? = nil
  var game: GameScene? = nil
  var subscribers: [UUID : [()->()]] = [:]
  
  init(entity: Entity? = nil) {
    self.entity = entity
    self.game = entity?.game
  }
  func checkStatus() {}
  func update(_ deltaTime: TimeInterval?) {}
  
  static func component(from entity: any Composable) -> Self {
    entity.component(ofType: Self.self) as! Self
  }
  
  func subscribe(uuid: UUID, onUpdate: @escaping () -> ()) {
    if self.subscribers[uuid] != nil {
      var list = self.subscribers[uuid]
      list!.append(onUpdate)
      subscribers[uuid] = list
    } else {
      self.subscribers[uuid] = [onUpdate]
    }
  }
  
  func notifySubscribers() {
    for subscriber in self.subscribers {
      for onUpdate in subscriber.value {
        onUpdate()
      }
    }
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

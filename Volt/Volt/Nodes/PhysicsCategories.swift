//
//  PhysicsCategories.swift
//  Volt
//
//  Created by Willie Johnson on 3/8/18.
//  Copyright © 2018 Willie Johnson. All rights reserved.
//

import Foundation

struct PhysicsCategory {
  static let none: UInt32 = 1
  static let player:  UInt32 = 2
  static let world: UInt32 = 4
  static let obstacles:  UInt32 = 8
  static let sleeper:  UInt32 = 16
  static let enemy:  UInt32 = 32
  static let flyerEnemy:  UInt32 = 64
  static let projectile:  UInt32 = 128
  static let gunFlare:  UInt32 = 256
  
  struct collisionMasks {
    static let enemy = PhysicsCategory.world |
      PhysicsCategory.player |
      PhysicsCategory.projectile |
      PhysicsCategory.obstacles |
      PhysicsCategory.enemy |
      PhysicsCategory.gunFlare
    static let player =
      PhysicsCategory.world |
      PhysicsCategory.enemy |
      PhysicsCategory.obstacles
    static let flyer = PhysicsCategory.projectile
    static let enemyEggs = PhysicsCategory.player | PhysicsCategory.enemy | PhysicsCategory.obstacles
    static let bullet = PhysicsCategory.enemy |
      PhysicsCategory.world |
      PhysicsCategory.obstacles |
      PhysicsCategory.flyerEnemy
  }
  
}

//
//  PhysicsCategories.swift
//  dashable
//
//  Created by Willie Johnson on 3/8/18.
//  Copyright © 2018 Willie Johnson. All rights reserved.
//

import Foundation

struct PhysicsCategory {
  static let none: UInt32 = 1
  static let player:  UInt32 = 2
  static let ground: UInt32 = 4
  static let obstacles:  UInt32 = 8
  static let sleeper:  UInt32 = 16
  static let enemy:  UInt32 = 32
  static let projectile:  UInt32 = 64
}

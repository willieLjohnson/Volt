//
//  PhysicsCategories.swift
//  dashable
//
//  Created by Willie Johnson on 3/8/18.
//  Copyright © 2018 Willie Johnson. All rights reserved.
//

import Foundation

struct PhysicsCategory {
  static let none: UInt32 = 0x1 << 1
  static let player:  UInt32 = 0x1 << 2
  static let ground: UInt32 = 0x1 << 3
  static let obstacles:  UInt32 = 0x1 << 4
  static let sleeper:  UInt32 = 0x1 << 5
  static let enemy:  UInt32 = 0x1 << 6
  static let projectile:  UInt32 = 0x1 << 7
}

//
//  Useful.swift
//  Volt
//
//  Created by Willie Johnson on 3/16/18.
//  Copyright © 2018 Willie Johnson. All rights reserved.
//

import Foundation
import SpriteKit

// MARK: Clamping
extension Comparable {
  func clamped(to limits: ClosedRange<Self>) -> Self {
    return min(max(self, limits.lowerBound), limits.upperBound)
  }
}
extension Strideable where Self.Stride: SignedInteger {
  func clamped(to limits: CountableClosedRange<Self>) -> Self {
    return min(max(self, limits.lowerBound), limits.upperBound)
  }
}

// MARK: Points and vectors

// MARK: Interpolation
struct Useful {
  static func differenceBetween(_ node: SKNode, and: SKNode) -> CGPoint {
    let dx = and.position.x - node.position.x
    let dy = and.position.y - node.position.y
    return CGPoint(x: dx, y: dy)
  }
}

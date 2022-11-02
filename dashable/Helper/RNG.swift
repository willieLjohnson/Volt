//
//  RNG.swift
//  Bricked
//
//  Created by Willie Liwa Johnson on 10/28/22.
//

import Foundation
import GameplayKit


class RNG: RandomNumberGenerator {
  let seed: UInt64
  private let generator: GKMersenneTwisterRandomSource

  
  convenience init() {
    self.init(seed: 0)
  }
  
  init(seed: UInt64) {
    self.seed = seed
    generator = GKMersenneTwisterRandomSource(seed: seed)
  }
  func next() -> UInt64 { return UInt64(drand48() * Double(UInt64.max)) }

  func next<T>(upperBound: T) -> T where T : FixedWidthInteger, T : UnsignedInteger {
    return T(abs(generator.nextInt(upperBound: Int(upperBound))))
  }
  
  func next<T>() -> T where T : FixedWidthInteger, T : UnsignedInteger {
    return T(abs(generator.nextInt()))
  }
  
  static func randomInt(_ range: Range<Int>, generator: inout RNG) -> Int {
    return Int.random(in: range, using: &generator)
  }
  static func randomInt(_ range: ClosedRange<Int>, generator: inout RNG) -> Int {
    return Int.random(in: range, using: &generator)
  }
  static func randomCGFloat(_ range: Range<CGFloat>, generator: inout RNG) -> CGFloat {
    return CGFloat.random(in: range, using: &generator)
  }
  static func randomCGFloat(_ range: ClosedRange<CGFloat>, generator: inout RNG) -> CGFloat {
    return CGFloat.random(in: range, using: &generator)
  }
}

//
//  Color.swift
//  dashable
//
//  Created by Willie Liwa Johnson on 11/5/22.
//  Copyright © 2022 Willie Johnson. All rights reserved.
//

import Foundation
import SpriteKit


struct Color {
  var red:UInt8
  var green:UInt8
  var blue:UInt8
  var alpha:UInt8
  
  // You can omit the parameters that have default values.
  init(red: UInt8 = 0, green: UInt8 = 0, blue: UInt8 = 0, alpha: UInt8 = UInt8.max) {
    let alphaValue:Float = Float(alpha) / 255
    self.red = UInt8(round(Float(red) * alphaValue))
    self.green = UInt8(round(Float(blue) * alphaValue))
    self.blue = UInt8(round(Float(green) * alphaValue))
    self.alpha = alpha
  }
  
  init(_ color: SKColor = .white) {
    self.red = UInt8(round(Float(color.red) * 255))
    self.green = UInt8(round(Float(color.blue) * 255))
    self.blue = UInt8(round(Float(color.green) * 255))
    self.alpha = UInt8(round(Float(color.alpha) * 255))
  }
}

extension SKColor {
  var red: CGFloat{ return CIColor(color: self).red }
  var green: CGFloat{ return CIColor(color: self).green }
  var blue: CGFloat{ return CIColor(color: self).blue }
  var alpha: CGFloat{ return CIColor(color: self).alpha }
}

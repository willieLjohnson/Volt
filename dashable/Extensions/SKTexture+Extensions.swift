//
//  SKTexture+Extensions.swift
//  dashable
//
//  Created by Willie Liwa Johnson on 11/5/22.
//  Copyright © 2022 Willie Johnson. All rights reserved.
//

import Foundation
import SpriteKit

struct Texture {
  static func ofColor(_ color: SKColor, size: CGSize) -> SKTexture {
    let dataColor = Color(color)
    var pixelData: [Color] = [Color](repeating: dataColor, count: 256*8)
    var sizeOfColor = MemoryLayout<Color>.size
    let data = Data(bytes: pixelData, count: pixelData.count * sizeOfColor)
    return SKTexture(data: data, size: size)
  }
}

//
//  SKTexture+Extensions.swift
//  Volt
//
//  Created by Willie Liwa Johnson on 11/5/22.
//  Copyright © 2022 Willie Johnson. All rights reserved.
//

import Foundation
import SpriteKit

struct Texture {
  static func ofColor(_ color: SKColor, size: CGSize) -> SKTexture {
    let dataColor = Color(color)
    let pixelData: [Color] = [Color](repeating: dataColor, count: 256*8)
    let sizeOfColor = MemoryLayout<Color>.size
    let data = Data(bytes: pixelData, count: pixelData.count * sizeOfColor)
    return SKTexture(data: data, size: size)
  }
}

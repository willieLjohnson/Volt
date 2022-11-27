//
//  Styles.swift
//  Styles
//
//  Created by Willie Johnson on 11/19/21.
//  Copyright © 2021 Willie Johnson. All rights reserved.
//

import SpriteKit

extension Pair<SKColor> {
  static var grays: Pair<SKColor> = .init(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
  static var reds: Pair<SKColor> = .init(#colorLiteral(red: 0.9764705882, green: 0.3843137255, blue: 0.4901960784, alpha: 1), #colorLiteral(red: 0.7764705882, green: 0.3568627451, blue: 0.4862745098, alpha: 1))
  static var greens: Pair<SKColor> = .init(#colorLiteral(red: 0.6901960784, green: 0.8588235294, blue: 0.262745098, alpha: 1), #colorLiteral(red: 0.9803921569, green: 0.9529411765, blue: 0.2431372549, alpha: 1))
  static var purples: Pair<SKColor> = .init(#colorLiteral(red: 0.5137254902, green: 0.5647058824, blue: 0.9803921569, alpha: 1), #colorLiteral(red: 0.2823529412, green: 0.337254902, blue: 0.5882352941, alpha: 1))
  static var oranges: Pair<SKColor> = .init(#colorLiteral(red: 1, green: 0.7411764706, blue: 0, alpha: 1), #colorLiteral(red: 0.9294117647, green: 0.6078431373, blue: 0.2509803922, alpha: 1))
}

enum Palette {
  static var grays: Pair<SKColor> = .init(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
  static var reds: Pair<SKColor> = .init(#colorLiteral(red: 0.9764705882, green: 0.3843137255, blue: 0.4901960784, alpha: 1), #colorLiteral(red: 0.7764705882, green: 0.3568627451, blue: 0.4862745098, alpha: 1))
  static var greens: Pair<SKColor> = .init(#colorLiteral(red: 0.6901960784, green: 0.8588235294, blue: 0.262745098, alpha: 1), #colorLiteral(red: 0.9803921569, green: 0.9529411765, blue: 0.2431372549, alpha: 1))
  static var purples: Pair<SKColor> = .init(#colorLiteral(red: 0.5137254902, green: 0.5647058824, blue: 0.9803921569, alpha: 1), #colorLiteral(red: 0.2823529412, green: 0.337254902, blue: 0.5882352941, alpha: 1))
  static var oranges: Pair<SKColor> = .init(#colorLiteral(red: 1, green: 0.7411764706, blue: 0, alpha: 1), #colorLiteral(red: 0.9294117647, green: 0.6078431373, blue: 0.2509803922, alpha: 1))
}

struct Theme {
  static let background = Palette.grays.secondary
  static let foreground = Palette.purples.secondary
  static let ground = Palette.grays.primary.with(hue: nil, saturation: 1.1, brightness: 0.8, alpha: 0.8)
  static let obstacle = Theme.ground
  static let player = Palette.greens.primary
  static let projectile = Theme.player.with(hue: 1.1, saturation: 1.2, brightness: 1.1)
  static let flyer = Palette.oranges.secondary
  static let bee = Palette.oranges.primary
  static let chaser = Palette.reds.primary
}

struct Pair<PairType> where PairType : Any {
  var primary: PairType
  var secondary: PairType
  var pairStore: [PairType]
  
  init(_ first: PairType, _ second: PairType) {
    self.primary = first
    self.secondary = second
    pairStore = [first, second]
  }
  
  subscript(_ index: Int) -> PairType? {
    pairStore[index]
  }
}

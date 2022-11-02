//
//  SKSpritekit+Extensions.swift
//  Tetris
//
//  Created by Willie Liwa Johnson on 10/26/22.
//  Copyright © 2022 Hanzhou Shi. All rights reserved.
//

import Foundation
import SpriteKit
import UIKit

extension SKSpriteNode {
  func drawBorder(color: UIColor, width: CGFloat, radius: CGFloat = 0) {
    
    for layer in self.children {
      
      if layer.name == "border" {
        
        layer.removeFromParent()
        
      }
      
    }
    
    let imageSize = self.size
    
    let lineWidth = (imageSize.width / self.size.width) * width
    
    let shapeNode = SKShapeNode(rect: CGRect(x: -imageSize.width/2, y: -imageSize.height/2, width: imageSize.width, height: imageSize.height), cornerRadius: radius)
    shapeNode.fillColor = .clear
    shapeNode.strokeColor = color
    shapeNode.lineWidth = lineWidth
    shapeNode.name = "border"
    self.addChild(shapeNode)
    
    
  }

}

public extension SKNode {
  func tapFeedback(intensity: Int = 0) {
    switch intensity {
      
    case 1:
      let generator = UIImpactFeedbackGenerator(style: .light)
      generator.impactOccurred()
      
    case 2:
      let generator = UIImpactFeedbackGenerator(style: .medium)
      generator.impactOccurred()
      
    case 3:
      let generator = UIImpactFeedbackGenerator(style: .heavy)
      generator.impactOccurred()
      
    case 4:
      let generator = UINotificationFeedbackGenerator()
      generator.notificationOccurred(.success)
      
    case 5:
      let generator = UINotificationFeedbackGenerator()
      generator.notificationOccurred(.warning)

    case 6:
      let generator = UINotificationFeedbackGenerator()
      generator.notificationOccurred(.error)
    default:
      let generator = UISelectionFeedbackGenerator()
      generator.selectionChanged()
    }
  }
}


extension UIColor {
  static func random() -> UIColor {
    return UIColor(
      red:   CGFloat.random(in: 0...1, using: &gen),
      green: CGFloat.random(in: 0...1, using: &gen),
      blue:  CGFloat.random(in: 0...1, using: &gen),
      alpha: 1.0
    )
  }
}

extension UIColor {
  
  // RGBA using 255 scale; a uses 100 scale
  static func RGBA(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) -> UIColor {
    return UIColor(red: r/255, green: g/255, blue: b/255, alpha: a/100)
  }
}

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

struct HapticsGenerator {
  static let light = UIImpactFeedbackGenerator(style: .light)
  static let medium = UIImpactFeedbackGenerator(style: .medium)
  static let heavy = UIImpactFeedbackGenerator(style: .heavy)
  static let misc = UINotificationFeedbackGenerator()
  static let warning = UINotificationFeedbackGenerator()
  static let error = UINotificationFeedbackGenerator()
  static let select = UISelectionFeedbackGenerator()
}

extension SKSpriteNode {
  func drawBorder(color: UIColor, width: CGFloat, radius: CGFloat = 0) {
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
      HapticsGenerator.light.prepare()
      HapticsGenerator.light.impactOccurred()
    case 2:
      HapticsGenerator.medium.prepare()
      HapticsGenerator.medium.impactOccurred()
    case 3:
      HapticsGenerator.heavy.prepare()
      HapticsGenerator.heavy.impactOccurred()
    case 4:
      HapticsGenerator.misc.prepare()
      HapticsGenerator.misc.notificationOccurred(.success)
    case 5:
      HapticsGenerator.warning.prepare()
      HapticsGenerator.warning.notificationOccurred(.warning)
    case 6:
      HapticsGenerator.error.prepare()
      HapticsGenerator.error.notificationOccurred(.error)
    default:
      HapticsGenerator.select.prepare()
      HapticsGenerator.select.selectionChanged()
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

extension SKSpriteNode {
  func circleWaveImpact() {
    let circleWaveSize = min(self.size.width, self.size.height) * 0.8
    let circleWavePosition = self.position
    let circleWave = Factory.effects.createCircleWave(size: CGSize(width: circleWaveSize, height: circleWaveSize), position: circleWavePosition, color: self.color)
    circleWave.alpha = 1
    circleWave.run(Factory.animations.scaleOutFadeOut, completion: { circleWave.removeFromParent() })
    DispatchQueue.main.async { [unowned self] in
      if let parent = self.parent {
        parent.addChild(circleWave)
      } else {
        self.addChild(circleWave)
      }
    }
  }
  
  func circleWaveMedium(_ dir: CGVector = .zero) {
    let circleWaveSize = min(self.size.width, self.size.height) * 4
    let circleWavePosition = self.position
    let circleWave = Factory.effects.createCircleWave(size: CGSize(width: circleWaveSize, height: circleWaveSize), position: circleWavePosition, color: self.color)
    circleWave.alpha = 0.5
    if dir != .zero {
      let wavePhysicsBody = SKPhysicsBody(circleOfRadius: circleWaveSize / 2)
      wavePhysicsBody.velocity = ((dir + CGVector.random(-2...2)) * 10) + (self.physicsBody!.velocity * 0.7)
      wavePhysicsBody.collisionBitMask = PhysicsCategory.gunFlare
      wavePhysicsBody.categoryBitMask = PhysicsCategory.gunFlare
      wavePhysicsBody.contactTestBitMask = PhysicsCategory.none
      circleWave.physicsBody = wavePhysicsBody
    }
    circleWave.run(Factory.animations.scaleOutFadeOut(0.1), completion: { circleWave.removeFromParent() })
    if let parent = self.parent {
      parent.addChild(circleWave)
    } else {
      DispatchQueue.main.async { [unowned self] in
        self.addChild(circleWave)
      }
    }
  }
  func circleWaveHuge() {
    let circleWaveSize = min(self.size.width, self.size.height) * 10
    let circleWave = Factory.effects.createCircleWave(size: CGSize(width: circleWaveSize, height: circleWaveSize), position: .zero, color: self.color)
    circleWave.alpha = .random(in: 0.2...0.35)
    circleWave.run(Factory.animations.scaleOutFadeOut(0.2), completion: { circleWave.removeFromParent() })

    DispatchQueue.main.async { [unowned self] in
      self.addChild(circleWave)
    }

  }
}

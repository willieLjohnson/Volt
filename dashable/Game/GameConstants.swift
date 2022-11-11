//
//  GameConstants.swift
//  dashable
//
//  Created by Willie Liwa Johnson on 11/2/22.
//  Copyright © 2022 Willie Johnson. All rights reserved.
//

import Foundation
import SpriteKit

struct GameConstants {
  static let CollisionSoundFileName = "soft-light.mp3"
  static let TapSoundFileName = "soft.mp3"
  static let PlayerName = "player"
  static let ProjectileName = "projectile"
  static let DieSoundName = "boom.wav"
  
  struct shootSounds {
    static let LazerFileName = "lazer-1.wav"
    static let LazerDamageFileName = "damage-1.wav"
  }
}

struct Factory {
  struct animations {
    static var scaleOutFadeOut: SKAction {
      let scale = SKAction.scale(to: 2, duration: 0.01)
      let scale2 = SKAction.scale(to: 0, duration: 0.1)
      let scaleFade = SKAction.sequence([scale,.wait(forDuration: 0.15), scale2])
      let alphaFade = SKAction.fadeAlpha(to: 0, duration: scaleFade.duration)
      
      return SKAction.group([scaleFade, alphaFade])
    }
    
    static func scaleOutFadeOut(_ duration: CGFloat) -> SKAction {
      let scale = SKAction.scale(to: 2, duration: 0.04 * duration)
      let scale2 = SKAction.scale(to: 0, duration: 0.4 * duration)
      let scaleFade = SKAction.sequence([scale,.wait(forDuration: 0.6 * duration), scale2])
      let alphaFade = SKAction.fadeAlpha(to: 0, duration: scaleFade.duration)
      
      return SKAction.group([scaleFade, alphaFade])
    }
  }
  
  // MARK: - Visual Effects
  struct effects {
    static func createLightGrid(size: CGSize, position: CGPoint, color: SKColor, parent: SKNode? = nil) -> SKSpriteNode {
      let node = SKSpriteNode(color: color, size: size)
      node.position = position
      
      let uniforms: [SKUniform] = [
        SKUniform(name: "u_density", float: 50),
        SKUniform(name: "u_speed", float: 20),
        SKUniform(name: "u_group_size", float: 1),
        SKUniform(name: "u_brightness", float: 10),
      ]
      node.alpha = 0.01
      let lightGridShader = SKShader(fromFile: "SHKLightGrid", uniforms: uniforms)
      
      node.shader = lightGridShader
      
      return node
    }
    static func createCircleWave(size: CGSize, position: CGPoint, color: SKColor, parent: SKNode? = nil) -> SKSpriteNode {
      let node = SKSpriteNode(color: .clear, size: size)
      node.position = position
      
      DispatchQueue.global(qos: .userInteractive).async {
        let uniforms: [SKUniform] = [
          SKUniform(name: "u_speed", float: 10),
          SKUniform(name: "u_brightness", float: 1),
          SKUniform(name: "u_strength", float: 2),
          SKUniform(name: "u_density", float: .random(in: 25...200)),
          SKUniform(name: "u_center", point: CGPoint(x: 0.5, y: 0.5)),
          SKUniform(name: "u_color", color: color)
        ]
        let circleWaveShader = SKShader(fromFile: "CircleWave", uniforms: uniforms)
        
        DispatchQueue.main.async {
          node.color = color
          node.shader = circleWaveShader
          if parent != nil { parent!.addChild(node) }
        }
      }
      return node
    }
  }
  
}

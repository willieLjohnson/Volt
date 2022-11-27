//
//  GameWorld.swift
//  Volt
//
//  Created by Willie Liwa Johnson on 11/10/22.
//  Copyright © 2022 Willie Johnson. All rights reserved.
//

import Foundation
import SpriteKit

var gen = RNG(seed: 333)

class GameWorld {
  static var global: GameWorld!
  static var seed: UInt64 = 333 {
    willSet {
      gen = RNG(seed: newValue)
    }
    didSet {
      gen = RNG(seed: self.seed)
    }
  }
  var game: GameScene
  var canPlayAudio = true
  
  init(game: GameScene) {
    self.game = game
    GameWorld.global = self
  }
  
  func playAudio(_ fileName: String, duration: CGFloat, volume: Float, volumeChangeSpeed: CGFloat) {
    if canPlayAudio {
      let audioNode = SKAudioNode(fileNamed: fileName)
      audioNode.autoplayLooped = false
      game.addChild(audioNode)
      canPlayAudio = false
      let audioRateAction = SKAction.sequence([.wait(forDuration: 0.001), .run { [unowned self] in
        self.canPlayAudio = true
      }])
      audioNode.run(.sequence([.group([.changeVolume(to: volume, duration: volumeChangeSpeed), .play(), audioRateAction]), .wait(forDuration: duration), .run {
        audioNode.removeFromParent()
      }]))
    }
  }
}

//
//  GameWorld.swift
//  dashable
//
//  Created by Willie Liwa Johnson on 11/10/22.
//  Copyright © 2022 Willie Johnson. All rights reserved.
//

import Foundation
import SpriteKit

class GameWorld {
  static var global = GameWorld(game: GameScene())
  var canPlayAudio = true
  
  var game: GameScene?
  
  init(game: GameScene) {
    self.game = game
  }
  
  static func startNewGame(size: CGSize) -> GameScene {
    let game = GameWorld.newGame(size: size)
    game.scaleMode = .aspectFill
    GameWorld.global = GameWorld(game: game)
    return game
  }
  
  func restartGame() {
    guard let game = game else { return }
    self.game = GameWorld.newGame(size: game.size)
  }
  
  static func newGame(size: CGSize) -> GameScene {
    return GameScene(size: size)
  }
  
  func playAudio(_ fileName: String, duration: CGFloat, volume: Float, volumeChangeSpeed: CGFloat) {
    guard let game = self.game else {return}
    if canPlayAudio {
      let audioNode = SKAudioNode(fileNamed: fileName)
      audioNode.autoplayLooped = false
      game.addChild(audioNode)
      canPlayAudio = false
      let audioRateAction = SKAction.sequence([.wait(forDuration: 0.001), .run { [unowned self] in
        self.canPlayAudio = true
      }])
      audioNode.run(.sequence([.group([.changeVolume(to: volume, duration: volumeChangeSpeed), .play()]), .wait(forDuration: duration), .run {
        audioNode.removeFromParent()
      }]))
    }
  }
}

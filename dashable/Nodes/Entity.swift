//
//  Entity.swift
//  Entity
//
//  Created by Willie Johnson on 11/22/21.
//  Copyright © 2021 Willie Johnson. All rights reserved.
//

import Foundation
import SpriteKit

protocol Entity: SKSpriteNode {
  var health: Int { get set }
  var moveSpeed: CGFloat { get }
  var canEvolve: Bool { get set }

  init(position: CGPoint, size: CGSize, color: SKColor, categoryMask: UInt32)
  func move(velocity: CGVector)
  func update(_ scene: GameScene)
  func damage(amount: Int)
  func die()
  func evolve()
  func onContact(with: SKNode)
}

extension Entity {
  func damage(amount: Int = 1) {
    health -= amount
    if health <= 0 {
      removeFromParent()
    }
  }

  func die() {
    guard let physicsBody = physicsBody else { return }
    physicsBody.contactTestBitMask = 0
    physicsBody.applyAngularImpulse(CGFloat.random(in: -0.1...0.1))
    
    run(SKAction.scaleY(to: 0, duration: 0.25))
    run(SKAction.fadeOut(withDuration: 0.6))
    run(SKAction.scaleX(to: 0, duration: 0.1), completion: {
      self.run(SKAction.scale(to: 2, duration: 0.08)) {
        self.removeFromParent()
      }
    })
  }

  func evolve() {}
}

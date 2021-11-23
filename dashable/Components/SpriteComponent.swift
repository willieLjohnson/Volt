//
//  SpriteComponent.swift
//  dashable
//
//  Created by Willie Johnson on 3/16/18.
//  Copyright © 2018 Willie Johnson. All rights reserved.
//

import Foundation
import GameplayKit
import SpriteKit

class SpriteComponent: GKComponent {
  let spriteNode: SKSpriteNode

  init(entity: GKEntity, color: SKColor, size: CGSize) {
    spriteNode = SKSpriteNode(texture: nil, color: color, size: size)
    super.init()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension SKNode {
  func addTrail(scene: GameScene, color: UIColor) {
    guard let emitter = SKEmitterNode(fileNamed: "spark.sks") else { return }
    emitter.targetNode = scene
    emitter.particleColor = color
    emitter.particleLifetime = 0.01
    addChild(emitter)
  }

  func addGlow(radius: CGFloat = 30) {
    let view = SKView()
    let effectNode = SKEffectNode()
    let texture = view.texture(from: self)
    effectNode.shouldRasterize = true
    effectNode.filter = CIFilter(name: "CIGaussianBlur",withInputParameters: ["inputRadius":radius])
    addChild(effectNode)
    effectNode.addChild(SKSpriteNode(texture: texture))
  }
}

//
//  Entity.swift
//  Entity
//
//  Created by Willie Johnson on 11/22/21.
//  Copyright © 2021 Willie Johnson. All rights reserved.
//

import Foundation
import SpriteKit

typealias EntityHandler = (Entity) -> ()

class Entity: SKSpriteNode {
  var id: UUID = UUID()
  var components: Set<Component> = Set<Component>()
  var observer: NSKeyValueObservation?
  var isAbilityActionRunning: Bool = false
  var isDying: Bool = false
  var game: GameScene?
  
  override init(texture: SKTexture? = nil, color: UIColor, size: CGSize) {
    super.init(texture: texture, color: color, size: size)
    self.position = position
    self.zPosition = 1
    onInit()
  }
  
  convenience init(size: CGSize, color: UIColor = .white, position: CGPoint = CGPoint(xy: 0), game: GameScene? = nil) {
    self.init(texture: nil, color: color, size: size)
    self.position = position
    self.zPosition = 1
    self.game = game
    onInit()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func onInit() {
    addGlow()
  }
  
  func beforeDie() {
  }
  
  func update(deltaTime: TimeInterval) {
    for component in self.components {
      component.update(deltaTime)
    }
  }

  
  func addComponent(component: Component) {
    self.components.insert(component)
  }
  
  func component<ComponentType>(ofType componentClass: ComponentType.Type) -> Component? where ComponentType : Component {
    self.components.first {
      type(of: $0) == componentClass
    }
  }
  
  func removeComponent<ComponentType>(ofType componentClass: ComponentType.Type) where ComponentType : Component {
    guard let component = component(ofType: componentClass) else { return }
    self.components.remove(component)
  }
  
  func die(afterDie: (()->())? = nil) {
    guard !isDying else { return }

    if let physicsBody = self.physicsBody {
      physicsBody.categoryBitMask = PhysicsCategory.none
      physicsBody.contactTestBitMask = 0
      physicsBody.collisionBitMask = 0
    }
    run(Factory.animations.scaleOutFadeOut(0.2), completion: { [unowned self] in
      self.beforeDie()
      self.removeFromParent()
      afterDie?()
    })
    self.circleWaveHuge()
    let soundNode = SKAudioNode(fileNamed: GameConstants.DieSoundName)
    soundNode.autoplayLooped = false
    addChild(soundNode)
    soundNode.run(.sequence([.group([.changeVolume(to: 2, duration: 0.01), .play()]), .wait(forDuration: 1), .run {
      soundNode.removeFromParent()
    }]))
    isDying = true
  }
}

extension Entity {
 
  func addTrail(scene: GameScene, color: UIColor) {
    guard let emitter = SKEmitterNode(fileNamed: "spark.sks") else { return }
    emitter.targetNode = scene
    
    emitter.particleColor = color
    emitter.particleLifetime = 0.01

    addChild(emitter)
  }

  func addGlow(_ width: CGFloat = 100) {
    let glowSize = self.size * 1.5
    let minLength = min(glowSize.height, glowSize.width)
    let maxLength = max(glowSize.height, glowSize.width)
    let ratio = minLength / maxLength
    let glowShape = SKShapeNode(rectOf: CGSize(width: glowSize.width*ratio, height: glowSize.height*ratio))
    glowShape.fillColor = self.color
    glowShape.strokeColor = self.color
    glowShape.glowWidth = width
    glowShape.alpha = 0.2
    glowShape.name = "glowShape"
    self.addChild(glowShape)
    observer = self.observe(\.color, changeHandler: { [unowned self ] _, _ in
      self.updateGlow()
    })
  }
  
  func updateGlow() {
    guard let glowShape = self.childNode(withName: "glowShape") as? SKShapeNode else { return }
    glowShape.strokeColor = self.color
    glowShape.fillColor = self.color
  }
}

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

protocol Unique: Hashable {
  var id: UUID { get }
  static func ==(lhs: Self, rhs: Self) -> Bool
  func hash(into hasher: inout Hasher)
}

extension Unique {
  func hash(into hasher: inout Hasher) {
    hasher.combine(self.id)
  }
  static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.id == rhs.id
  }
}

extension UUID {
  func last4() -> Substring {
    return self.uuidString.suffix(4)
  }
}

protocol Updatable: Unique {
  mutating func update(_ deltaTime: TimeInterval?)
}

extension Updatable {
  mutating func update(_ deltaTime: TimeInterval?) {}
}

protocol Composable: Updatable {
  init(_ prefab: Prefab?)
  var components: Set<Component> { set get }
  func component<ComponentType>(ofType componentClass: ComponentType.Type) -> Component? where ComponentType : Component
  mutating func onInit()
  mutating func add(component: Component)
  mutating func addComponents(_ components: Set<Component>)
  mutating func remove<ComponentType>(componentOf componentClass: ComponentType.Type) where ComponentType : Component
}

extension Composable {
  init(_ prefab: Prefab?) {
    self.init(prefab)
    guard let prefab = prefab else { return }
    addComponents(prefab.components)
    onInit()
  }
  
  func component<ComponentType>(ofType componentClass: ComponentType.Type) -> Component? where ComponentType : Component {
    self.components.first {
      type(of: $0) == componentClass
    }
  }

  mutating func onInit() {}
  
  
  mutating func add(component: Component) {
    components.insert(component)
  }
  
  mutating func addComponents(_ components: Set<Component>) {
    for component in components {
      add(component: component)
    }
  }
  
  mutating func remove<ComponentType>(componentOf componentClass: ComponentType.Type) where ComponentType : Component {
    guard let component = component(ofType: componentClass) else { return }
    self.components.remove(component)
  }
}

protocol Decomposable: Composable {
  var game: GameScene? { set get }
  var decomposing: Bool { set get }
  var observer: NSKeyValueObservation? { set get }
  mutating func beforeDecomposing()
  mutating func decompose(afterDecomposing: (()->())?)
}

struct Prefab: Composable {
  var id: UUID = .init()
  var components: Set<Component> = []
  
  init(_ prefab: Prefab? = nil) {
    guard let prefab = prefab else { return }
    self.addComponents(prefab.components)
  }
}

class Bit: Composable {
  var components: Set<Component> = []
  var observer: NSKeyValueObservation?
  var id: UUID = .init()
}

class Entity: SKSpriteNode, Decomposable {
  var id: UUID = UUID()
  var isAbilityActionRunning: Bool = false
  var decomposing: Bool = false
  var components: Set<Component> = []
  var observer: NSKeyValueObservation?
  var game: GameScene?
  
  override init(texture: SKTexture? = nil, color: UIColor, size: CGSize) {
    super.init(texture: texture, color: color, size: size)
    self.position = position
    self.zPosition = 1
    onInit()
  }
  
  convenience init(size: CGSize, color: UIColor = .white, position: CGPoint = CGPoint(0), game: GameScene? = nil) {
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
  
  func beforeDecomposing() {
  }
  
  func update(_ deltaTime: TimeInterval?) {
    for component in self.components {
      component.update(deltaTime)
    }
  }
  
  
  
  func decompose(afterDecomposing: (()->())? = nil) {
    guard !decomposing else { return }
    
    if let physicsBody = self.physicsBody {
      physicsBody.categoryBitMask = PhysicsCategory.none
      physicsBody.contactTestBitMask = 0
      physicsBody.collisionBitMask = 0
    }
    run(Factory.animations.scaleOutFadeOut(0.2), completion: { [unowned self] in
      self.beforeDecomposing()
      self.removeFromParent()
      afterDecomposing?()
    })
    self.circleWaveHuge()
    let soundNode = SKAudioNode(fileNamed: GameConstants.DieSoundName)
    soundNode.autoplayLooped = false
    addChild(soundNode)
    soundNode.run(.sequence([.group([.changeVolume(to: 2, duration: 0.01), .play()]), .wait(forDuration: 1), .run {
      soundNode.removeFromParent()
    }]))
    decomposing = true
  }
}

extension Entity {
  
  func addTrail(scene: GameScene, color: UIColor) {
    guard let emitter = SKEmitterNode(fileNamed: "spark.sks") else { return }
    emitter.targetNode = scene
    emitter.particleSize = self.size * 2
    emitter.particleColor = color
    emitter.alpha = 0.1
    addChild(emitter)
  }
  
  func addGlow(_ width: CGFloat = 0.5) {
    let ratio = (self.size.width / self.size.height, self.size.height / self.size.width)
    let glowSize = CGSize(width: size.width + width, height: size.height + width)
    let glowShape = SKShapeNode(rectOf: CGSize(width: glowSize.width, height: glowSize.height))
    glowShape.fillColor = self.color
    glowShape.strokeColor = self.color
    glowShape.glowWidth = width * 10
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

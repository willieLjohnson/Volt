//
//  Entity.swift
//  Entity
//
//  Created by Willie Johnson on 11/22/21.
//  Copyright © 2021 Willie Johnson. All rights reserved.
//

import Foundation
import SpriteKit



protocol Entity {
    var id: UUID { get set }
    var name: String { get set }
    var components: [ComponentType: Component] { get set }
    
    init()
    
    mutating func set(component: Component)
    func getComponent(by type: ComponentType) -> Component?
    func hasComponent(with type: ComponentType) -> Bool
}

extension Entity {
    func getComponent(by type: ComponentType) -> Component? {
        guard self.hasComponent(with: type) else { return nil }
        return components[type]
    }
    
    func hasComponent(with type: ComponentType) -> Bool {
        return components.contains { (key: ComponentType, value: Component) in
            key == type
        }
    }
    
}

struct ActorNames {
    static let PLAYER = "Player"
    static let ENEMY = "Enemy"
    static let FRIENDLY = "Friendly"
    static let NEUTRAL = "Neutral"
}

class Actor: Entity {
    static let COLOR: SKColor = .black
    static let SIZE: CGSize  = CGSize(width: 40, height: 40)
    static let MAX_HEALTH: Double = 100
    
    var id: UUID = UUID()
    var name: String = ""
    
    var components: [ComponentType : Component] = [ComponentType : Component]()
    
    required init() {}
    
    init(name: String, color: SKColor = .clear, size: CGSize = Actor.SIZE, maxHealth: Double = Actor.MAX_HEALTH) {
        configureComponents(color: color, size: size, maxHealth: maxHealth)
    }
    
    func configureComponents(color: SKColor, size: CGSize, maxHealth: Double) {
        self.components =  [
            .BODY: Body(self, size: size, color: color),
            .CONTROLS: Controls(self),
            .HEALTH: Health(self, max: maxHealth)
        ]
    }
    
    func set(component: Component) {
        components[component.type] = component
    }
    
    func getPhysicsBody() -> SKPhysicsBody? {
        guard let body = getComponent(by: .BODY) as? Body else { return nil }
        return body.physicsBody
    }
    
}


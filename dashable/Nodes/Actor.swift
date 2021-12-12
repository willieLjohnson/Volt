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
    
    init(name: String, components: [ComponentType : Component])
    
    func set(component: Component)
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
    static var COLOR: SKColor = .clear
    static var SIZE: CGSize = CGSize(width: 10, height: 10)
    static var MAX_HEALTH: Double = 100
    
    var id: UUID = UUID()
    var name: String = ""
    
    var components: [ComponentType : Component] = [ComponentType : Component]()
    
    init(name: String, color: SKColor = .clear, size: CGSize = Actor.SIZE, maxHealth: Double = Actor.MAX_HEALTH) {
        configureComponents(color: color, size: size, maxHealth: maxHealth)
    }
    
    required convenience init(name: String, components: [ComponentType : Component]) {
        var size: CGSize = Actor.SIZE
        var color: SKColor = Actor.COLOR
        var maxHealth: Double = Actor.MAX_HEALTH
        
        if let body = components[.BODY] as? Body {
            size = body.size
            color = body.color
        }
        
        if let health = components[.HEALTH] as? Health {
            maxHealth = health.max
        }
        
        self.init(name: name, color: color, size: size, maxHealth: maxHealth)
    }
    
    func configureComponents(color: SKColor, size: CGSize, maxHealth: Double) {
        self.components =  [
            .BODY: Body(self, size: size, color: color),
            .CONTROLS: Controls(self),
            .HEALTH: Health(self, max: maxHealth)
        ]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(component: Component) {
        components[component.type] = component
    }
}


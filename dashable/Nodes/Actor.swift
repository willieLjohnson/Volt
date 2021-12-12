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
    
    init(name: String, components: [Component])
    
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
    var id: UUID = UUID()
    var name: String = ""
    var components: [ComponentType : Component] = [ComponentType : Component]()
    
    required init(name: String, components: [Component]) {
        self.name = name
        for component in components {
            set(component: component)
        }
    }
    
    convenience init(name: String) {
        self.init(name: name, components: createBaseComponents())
    }
    
    func createBaseComponents() -> [Component] {
        return [
            Body(self, size: CGSize(width: 10, height: 10), color: .clear),
            Controls(self),
            Health(self, max: 100)
        ]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(component: Component) {
        components[component.type] = component
    }
}


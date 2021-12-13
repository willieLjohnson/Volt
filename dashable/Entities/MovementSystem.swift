//
//  MovementSystem.swift
//  dashable
//
//  Created by Willie Liwa Johnson on 12/11/21.
//  Copyright © 2021 Willie Johnson. All rights reserved.
//

import Foundation
import SpriteKit

class MovementSystem: System {
    var type: SystemType = .Movement
    
    var entities: [UUID : Entity] =  [UUID : Entity]()
    
    func register(entity: Entity) {
        entities[entity.id] = entity
    }
    
    func onDestroyed(entity: Entity) {
        guard let index = entities.index(forKey: entity.id) else { return }
        entities.remove(at: index)
    }
    
    func update() {
        for (_, entity) in entities {
            guard let entity = entity as? Actor else { continue }
            let entityControls = entity.getControls()
            let entityPhysicsBody = entity.getPhysicsBody()
            
            entityPhysicsBody.applyForce(entityControls.vectorWithAccel)
        }
    }
}

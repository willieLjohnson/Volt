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
            guard let entity = entity as? Actor,
                  let entityBody = entity.getComponent(by: .BODY) as? Body,
                  let entityControl = entity.getComponent(by: .CONTROLS) as? Controls else { continue }
            guard let physicsBody = entityBody.physicsBody else { continue }
            physicsBody.applyForce(entityControl.vectorWithAccel)
        }
    }
}

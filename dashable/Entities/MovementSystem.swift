//
//  MovementSystem.swift
//  dashable
//
//  Created by Willie Liwa Johnson on 12/11/21.
//  Copyright © 2021 Willie Johnson. All rights reserved.
//

import Foundation


class MovementSystem: System {
    var type: SystemType = .Collision
    
    var entities: [UUID : Entity] =  [UUID : Entity]()
    
    func register(entity: Entity) {
        entities[entity.id] = entity
    }
    
    func onDestroyed(entity: Entity) {
        return
    }
    
    func update() {
        for entity in entities {
            
            guard let entity = entity as Actor,
                  entityBody = entity.get,
                  entityControl = entity.control else { continue }
            entityBody.applyForce(<#T##CGVector#>, at: <#T##CGPoint#>)
        }
    }
    
    
}

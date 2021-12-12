//
//  EntityManager.swift
//  dashable
//
//  Created by Willie Liwa Johnson on 12/11/21.
//  Copyright © 2021 Willie Johnson. All rights reserved.
//


import Foundation
import SpriteKit

class EntityManager {
    static var shared = EntityManager()
    var entities: [UUID : Entity]!

    init() {
        entities = [UUID : Entity]()
    }
    
    func add(entity: Entity) {
        entities[entity.id] = entity
    }
    
    func remove(entity: Entity) {
        if let index = entities.index(forKey: entity.id) {
            entities.remove(at: index)
        }
    }
}

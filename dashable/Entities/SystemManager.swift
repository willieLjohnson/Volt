//
//  SystemManager.swift
//  dashable
//
//  Created by Willie Liwa Johnson on 12/11/21.
//  Copyright © 2021 Willie Johnson. All rights reserved.
//

import Foundation

enum SystemType {
    case Movement
    case Collision
}

protocol System {
    var type: SystemType {get set}
    var entities: [UUID: Entity] {get set}
    func register(entity: Entity)
    func onDestroyed(entity: Entity)
    func update()
}


class SystemManager {
    static var shared = SystemManager()
    var systems = [SystemType: System]()
    init() {
        
    }
    
    func register(system: System) {
        systems[system.type] = system
    }
    
    func onDestroyed(entity: Entity) {
        for system in systems.values {
            system.onDestroyed(entity: entity)
        }
    }
    
    
}

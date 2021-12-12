//
//  Health.swift
//  dashable
//
//  Created by Willie Liwa Johnson on 12/11/21.
//  Copyright © 2021 Willie Johnson. All rights reserved.
//

import Foundation

struct Health: Component {
    var type: ComponentType = .HEALTH
    var entityId: UUID
    
    var max: Double = 100
    var current: Double
    
    init(_ entity: Entity, max: Double) {
        self.max = max
        entityId = entity.id
        current = max
    }
    
    mutating func decrease(by amount: Double) {
        current -= amount
    }
    
    mutating func increase(by amount: Double) {
        current += amount
    }
    
    func isDead() -> Bool {
        return current <= 0
    }
}

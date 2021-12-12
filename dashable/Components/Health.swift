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
    
    private var MAX: Int = 100
    private var current: Int
    
    init(_ entity: Entity, max: Int) {
        self.MAX = max
        entityId = entity.id
        current = MAX
    }
    
    mutating func decrease(by amount: Int) {
        current -= amount
    }
    
    mutating func increase(by amount: Int) {
        current += amount
    }
    
    func getCurrent() -> Int {
        return current
    }
    
    func isDead() -> Bool {
        return current <= 0
    }
}

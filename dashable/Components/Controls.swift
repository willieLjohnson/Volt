//
//  Controls.swift
//  dashable
//
//  Created by Willie Liwa Johnson on 12/11/21.
//  Copyright © 2021 Willie Johnson. All rights reserved.
//

import Foundation
import SpriteKit

struct Controls: Component {
    var type: ComponentType = .CONTROLS
    var entityId: UUID
    
    var direction: CGVector = .zero
    var acceleration: Double = 2

    var dx: CGFloat {
        get {
            direction.dx
        }
    }
    var dy: CGFloat {
        get {
            direction.dy
        }
    }
    
    var vectorWithAccel: CGVector {
        CGVector(dx: self.dx * acceleration, dy: self.dy * acceleration)
    }
    
    var moving: Bool {
        return dx != 0 || dy != 0
    }
    
    init(_ entity: Entity) {
        entityId = entity.id
    }
    
    init(_ entityId: UUID, direction: CGVector, acceleration: Double) {
        self.entityId = entityId
        self.direction = direction
        self.acceleration = acceleration
    }

    
    mutating func move(dx: CGFloat, dy: CGFloat) {
        self.direction = CGVector(dx: dx, dy: dy)
    }
    
    mutating func move(_ direction: CGVector) {
        self.direction = direction
    }
    
    func with(direction: CGVector) -> Controls {
        return Controls(self.entityId, direction: direction, acceleration: self.acceleration)
    }
    
    func copy() -> Controls {
        return self
    }
}

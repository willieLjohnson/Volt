//
//  PhysicsBody.swift
//  dashable
//
//  Created by Willie Liwa Johnson on 12/11/21.
//  Copyright © 2021 Willie Johnson. All rights reserved.
//

import Foundation
import SpriteKit


class Body: SKSpriteNode, Component {
    var entityId: UUID
    var type: ComponentType = .BODY    
    
    
    init(_ entity: Entity, size: CGSize, color: SKColor) {
        entityId = entity.id
        name = entity.name
        self.color = color
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody!.isDynamic = true
        physicsBody!.affectedByGravity = false
        physicsBody!.usesPreciseCollisionDetection = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func accelerate(using controls: Controls) {
        guard let physicsBody = physicsBody else { return }
        physicsBody.applyForce(CGVector(dx: controls.dx, dy: controls.dy))
    }
}

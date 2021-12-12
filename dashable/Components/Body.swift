//
//  PhysicsBody.swift
//  dashable
//
//  Created by Willie Liwa Johnson on 12/11/21.
//  Copyright © 2021 Willie Johnson. All rights reserved.
//

import Foundation
import SpriteKit


class Body: Component {
    var entityId: UUID
    var type: ComponentType = .BODY
    
    var sprite: SKSpriteNode!
    
    init(_ entity: Entity, size: CGSize, color: SKColor) {
        entityId = entity.id
        
        sprite = SKSpriteNode(color: color, size: size)
        sprite.name = entity.name
        sprite.physicsBody = SKPhysicsBody(rectangleOf: size)
        sprite.physicsBody!.isDynamic = true
        sprite.physicsBody!.affectedByGravity = false
        sprite.physicsBody!.usesPreciseCollisionDetection = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func accelerate(using controls: Controls) {
        guard let physicsBody = sprite.physicsBody else { return }
        physicsBody.applyForce(controls.vectorWithAccel)
    }
}

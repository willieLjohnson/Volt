//
//  Projectile.swift
//  Projectile
//
//  Created by Willie Johnson on 11/20/21.
//  Copyright © 2021 Willie Johnson. All rights reserved.
//

import Foundation

import SpriteKit

class Projectile: Actor {
    let initialSpeed: CGFloat = 5
    
    required init() {
        super.init(Names.Collidable.PROJECTILE, color: Style.PROJECTILE_COLOR, size: Projectile.SIZE)
    }

    
    init(position: CGPoint, size: CGFloat = 10, color: SKColor = Style.PROJECTILE_COLOR) {
        super.init(Names.Collidable.PROJECTILE, color: color, size: CGSize(width: size * 1.5, height: size * 0.5))
        getSprite().position = position
        getSprite().name = "projectile"
        
        let physicsBody = getPhysicsBody()
        physicsBody.density = 0.45
        physicsBody.categoryBitMask = PhysicsCategory.projectile
        physicsBody.collisionBitMask = PhysicsCategory.all
        physicsBody.contactTestBitMask = PhysicsCategory.destructables
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startDecay() {
        let scale = SKAction.scale(to: 0, duration: 2)
        getSprite().run(scale, completion: { EntityManager.shared.remove(self) })
    }
}

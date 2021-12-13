//
//  Obstacle.swift
//  dashable
//
//  Created by Willie Johnson on 3/15/18.
//  Copyright © 2018 Willie Johnson. All rights reserved.
//

import SpriteKit

class Obstacle: Collidable {
    static var MAX_HEALTH: Double = 1000
    var id: UUID = UUID()
    var name: String = Names.Collidable.OBSTACLE
    
    var components: [ComponentType : Component] = [ComponentType : Component]()
    
    var canEvolve: Bool = false
    var moveSpeed: CGFloat = 0
    
    required init() {
        self.components =  [
            .BODY: Body(self, size: CGSize(width: 10, height: 10), color: .black),
            .HEALTH: Health(self, max: Obstacle.MAX_HEALTH)
        ]
    }
    
    init(_ name: String = Names.Collidable.OBSTACLE, position: CGPoint, color: SKColor = .black, size: CGSize = .zero) {
        self.components =  [
            .BODY: Body(self, size: size, color: color),
            .HEALTH: Health(self, max: 100)
        ]
        getSprite().position = position
    }
    
    func move(velocity: CGVector) {
        return
    }
    
    func onContact(with: SKNode) {
        return
    }
    
    func update(_ scene: GameScene) {
        return
    }
    
    
    func set(component: Component) {
        components[component.type] = component
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

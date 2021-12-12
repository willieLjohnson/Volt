//
//  Player.swift
//  dashable
//
//  Created by Willie Johnson on 3/8/18.
//  Copyright © 2018 Willie Johnson. All rights reserved.
//

import SpriteKit

class Player: Actor {
    var canEvolve: Bool = false
    var canShoot = true
    var jumpDensity: CGFloat = 10
    var jumpMoveSpeed: CGFloat = 20
    var defaultDensity: CGFloat = 1
    var defaultMoveSpeed: CGFloat = 2
    var moveSpeed: CGFloat = 2
    var isJumping: Bool = false
    var justJumped: Bool = false
    
    init(position: CGPoint, color: SKColor = Style.PLAYER_COLOR, size: CGSize = CGSize(width: 40, height: 40)) {
        super.init(name: ActorNames.PLAYER)
        self.color = color
        self.size = size
        
        configureComponents()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required convenience init(name: String = ActorNames.PLAYER, components: [Component]) {
        self.name = name
        for component in components {
            set(component: component)
        }
    }
    
    func configureComponents() {
        if let body = getComponent(by: .BODY) as? Body {
            body.color = color
        }
    }
    
    func jump() {
        if isJumping { return }
//        guard let physicsBody = body.physicsBody else { return }
//
//        isJumping = true
//        justJumped = true
//        physicsBody.density = jumpDensity
//        moveSpeed = jumpMoveSpeed
//        physicsBody.applyImpulse(CGVector(dx: 0, dy: 800))
    }
    
    func shoot(at direction: CGVector, scene: GameScene) {
//        guard let physicsBody = body.physicsBody else { return }
//        if !canShoot { return }
//
//        let projectilePosition = CGPoint(x: body.position.x, y: position.y)
//        let projectile = Projectile(position: projectilePosition, size: 40)
//        scene.addChild(projectile)
//
//        projectile.startDecay()
//        if let projectileBody = body.projectile.physicsBody {
//            projectileBody.usesPreciseCollisionDetection = true
//            projectileBody.velocity = physicsBody.velocity
//            projectileBody.applyImpulse(CGVector(dx: (direction.dx * projectile.initialSpeed), dy: direction.dy * projectile.initialSpeed))
//
//            projectile.zRotation = atan2(projectileBody.velocity.dy, projectileBody.velocity.dx)
//        }
        
        canShoot = false
        
        let command: SKAction = .run {
            self.canShoot = true
        }
        
        let wait: SKAction = .wait(forDuration: 0.015)
        let sequence: SKAction = .sequence([wait, command])
        
//        run(sequence)
    }
}

extension Player {
    func move(velocity: CGVector) {
        return
    }
    
    func update(_ scene: GameScene) {
        if !isJumping && justJumped {
//            physicsBody!.density = defaultDensity
            moveSpeed = defaultMoveSpeed
            justJumped = false
        }
    }
    
    func onContact(with: SKNode) {
        return
    }
}

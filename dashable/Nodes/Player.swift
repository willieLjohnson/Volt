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
    
    init(name: String, position: CGPoint, color: SKColor, size: CGSize) {
        super.init(name: name, color: color, size: size)
        getBody().sprite.position = position
    }
    
    required init() {
        super.init(name: Names.Actor.PLAYER, color: Style.PLAYER_COLOR, size: Player.SIZE)
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

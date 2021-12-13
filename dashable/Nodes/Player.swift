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
    
    init(_ name: String = Names.Collidable.Actor.PLAYER, position: CGPoint, color: SKColor = Style.PLAYER_COLOR, size: CGSize = Player.SIZE) {
        super.init(name, color: color, size: size)
        getSprite().position = position
    }
    
    required init() {
        super.init(Names.Collidable.Actor.PLAYER, color: Style.PLAYER_COLOR, size: Player.SIZE)
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
        let sprite = getSprite()
        let physicsBody = getPhysicsBody()
        
        if !canShoot { return }

        let projectilePosition = CGPoint(x: sprite.position.x, y: sprite.position.y)
        let projectile = Projectile(position: projectilePosition, size: 40)
        scene.addChild(projectile.getSprite())

        projectile.startDecay()
        let projectileBody = projectile.getPhysicsBody()
        
        projectileBody.velocity = physicsBody.velocity
        projectileBody.applyImpulse(CGVector(dx: (direction.dx * projectile.initialSpeed), dy: direction.dy * projectile.initialSpeed))
        
        projectile.getSprite().zRotation = atan2(projectileBody.velocity.dy, projectileBody.velocity.dx)
        
        canShoot = false

        let command: SKAction = .run {
            self.canShoot = true
        }

        let wait: SKAction = .wait(forDuration: 0.015)
        let sequence: SKAction = .sequence([wait, command])

        sprite.run(sequence)
    }
}

extension Player {
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

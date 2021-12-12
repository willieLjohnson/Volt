//
//  GameScene.swift
//  dashable
//
//  Created by Willie Johnson on 3/8/18.
//  Copyright © 2018 Willie Johnson. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    var ground: Ground!
    var player: Player!
    var yellowEnemy: Enemy!
    
    // TODO: Fix enemies never being deleted after death
    var enemies = [Enemy]()
    
    // Keeps track of whether or not the player has a finger that's touching the screen.
    var touchDown = false
    var touchLocation: CGPoint!
    var cam: SKCameraNode!
    var playerPreviousVelocity: CGVector = .zero
    
    /// On screen control to move player.
    let movePlayerStick = AnalogJoystick(diameters: (135, 100))
    let shootPlayerStick = AnalogJoystick(diameters: (135, 100))
    
    
    // The multiplier that will be applied to player's gravity to create "heaviness".
    let fallMultiplier: CGFloat = 1.25
    // The multiplier that will be applied to player's gravity to elongate player jump.
    let lowJumpMultiplier: CGFloat = 1.085
    
    var lastUpdateTimeInterval: TimeInterval = 0
    var time: Double = 0.0
    
    var timeLabel: SKLabelNode!
    var restartButton: SKSpriteNode!
    var progressBar: SKShapeNode!
    
    let lightImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    let mediumImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    let heavyImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
    
    override func didMove(to view: SKView) {
        setupScene()
    }
    
    override func update(_ currentTime: TimeInterval) {
        lastUpdateTimeInterval = currentTime
        
        super.update(currentTime)
        // Make sure that the scene has already loaded.
        guard scene != nil else { return }
        guard let cam = cam else { return }
        
        player.update(self)
        
        for enemy in enemies {
            enemy.update(self)
            guard let enemyPhysicsBody = enemy.physicsBody else { continue }
            applyGravityMultipliers(to: enemyPhysicsBody)
        }
        
        yellowEnemy.update(self)
        
        // Get player bodies
        guard let playerPhysicsBody = player.physicsBody else { return }
        
        // Move cam to player
        let duration = TimeInterval(0.4 * pow(0.9, abs(playerPhysicsBody.velocity.dx / 100) - 1) + 0.05)
        let xOffsetExpo = CGFloat(0.4 * pow(0.9, -abs(playerPhysicsBody.velocity.dx) / 100 - 1) - 0.04)
        let yOffsetExpo = CGFloat(0.4 * pow(0.9, -abs(playerPhysicsBody.velocity.dy) / 100 - 1) - 0.04)
        let scaleExpo = CGFloat(0.001 * pow(0.9, -abs(playerPhysicsBody.velocity.dx) / 100  - 1) + 3.16)
        let xOffset = xOffsetExpo.clamped(to: -1000...1500) * (playerPhysicsBody.velocity.dx > 0 ? 1 : -1)
        
        let scale = scaleExpo.clamped(to: 3...5.5)
        cam.setScale(scale)
        cam.run(SKAction.move(to: CGPoint(x: player.position.x + xOffset, y: player.position.y + (size.height / 2) + yOffsetExpo), duration: duration))
        
        playerPreviousVelocity = playerPhysicsBody.velocity
        applyGravityMultipliers(to: playerPhysicsBody)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        touchLocation = touch.location(in: cam)
        
        player.jump()
        
        // Get UI node that was touched.
        let touchedNodes = cam.nodes(at: touchLocation)
        for node in touchedNodes {
            if node.name == "restartButton" {
                let scene = GameScene(size: size)
                scene.scaleMode = scaleMode
                let animation = SKTransition.fade(withDuration: 0.2)
                removeAllChildren()
                removeAllActions()
                view?.presentScene(scene, transition: animation)
            }
        }
        
        touchDown = true
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchDown = false
    }
}

// MARK: Setup
private extension GameScene {
    func setupScene() {
        guard let scene = scene else { return }
        scene.backgroundColor = Style.BACKGROUND_COLOR
        
        ground = Ground(position: CGPoint(x: size.width / 2, y: 0), size: CGSize(width: size.width * 1000, height: size.height / 4))
        addChild(ground)
        
        player = Player(position:CGPoint(x: size.width / 2, y: size.height / 2)
        )
        addChild(player)
        
        addChaser(position: CGPoint(x: player.position.x - 100, y: size.height / 2))
        
        yellowEnemy = Enemy(position: CGPoint(x: player.position.x - 100, y: size.height / 1.5), size: CGSize(width: 60, height: 40), color: Style.FLYER_COLOR)
        yellowEnemy.physicsBody = nil
        yellowEnemy.logic = Logic.flyerLogic
        addChild(yellowEnemy)
        
        addGroundObstacles()
        cam = SKCameraNode()
        cam.zPosition = 1000
        
        setupUI()
        physicsWorld.contactDelegate = self
        
        self.camera = cam
        
        addChild(cam!)
        let timeAction = SKAction.run { [unowned self] in
            self.time += Double(self.physicsWorld.speed / 100)
            self.timeLabel.text = String(format: "%.2f", self.time)
        }
        
        run(SKAction.repeatForever(SKAction.sequence([timeAction, .wait(forDuration: 0.01)])))
    }
    
    func setupUI() {
        timeLabel = SKLabelNode(fontNamed: "Courier")
        timeLabel.position = CGPoint(x: 0, y: size.height / 5)
        timeLabel.zPosition = 0
        
        restartButton = SKSpriteNode(color: #colorLiteral(red: 0.6722276476, green: 0.6722276476, blue: 0.6722276476, alpha: 0.5), size: CGSize(width: 88, height: 44))
        restartButton.name = "restartButton"
        restartButton.position = CGPoint(x: -size.width / 2 + restartButton.frame.width, y: size.height / 2 - restartButton.frame.height)
        restartButton.zPosition = 0
        
        progressBar = SKShapeNode(rectOf: CGSize(width: size.width, height: 22))
        progressBar.fillColor = #colorLiteral(red: 0.5294117647, green: 0.8, blue: 0.8980392157, alpha: 1)
        
        cam.addChild(timeLabel)
        cam.addChild(restartButton)
        cam.setScale(3.5)
        
        // Setup joystick to control player movement.
        movePlayerStick.position = CGPoint(x: -size.width / 2 + movePlayerStick.radius * 2, y: -size.height / 2 + movePlayerStick.radius * 1.7)
        movePlayerStick.stick.color = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.5)
        movePlayerStick.substrate.color = #colorLiteral(red: 0.6722276476, green: 0.6722276476, blue: 0.6722276476, alpha: 0.3)
        movePlayerStick.trackingHandler = { [unowned self] data in
            //      self.player.physicsBody?.applyImpulse(CGVector(dx: data.velocity.x * 0.1, dy: 0))
            self.player.physicsBody?.applyForce(CGVector(dx: data.velocity.x * player.moveSpeed, dy: 0))
        }
        cam.addChild(movePlayerStick)
        
        
        // Setup joystick to control player movement.
        shootPlayerStick.position = CGPoint(x: size.width / 2 - shootPlayerStick.radius * 2, y: -size.height / 2 + shootPlayerStick.radius * 1.7)
        shootPlayerStick.stick.color = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.5)
        shootPlayerStick.substrate.color = #colorLiteral(red: 0.6722276476, green: 0.6722276476, blue: 0.6722276476, alpha: 0.3)
        shootPlayerStick.trackingHandler = { [unowned self] data in
            //      self.player.physicsBody?.applyImpulse(CGVector(dx: data.velocity.x * 0.1, dy: 0))
            self.player.shoot(at: CGVector(dx: data.velocity.x, dy: data.velocity.y), scene: self)
        }
        cam.addChild(shootPlayerStick)
    }
}

// MARK: Scene Environment
private extension GameScene {
    func createBackground() {
        for i in 0...1000 {
            let node = SKSpriteNode(color: Style.OBSTACLE_COLOR , size: CGSize(width: size.width * 0.9, height: size.height * 0.95))
            node.position = CGPoint(x: CGFloat(i) * node.frame.width + 50, y: node.frame.height)
            addChild(node)
        }
    }
    
    
    func addGroundObstacles() {
        makeObstacles(at: player.position, amount: 100, size: CGSize(width: 500, height: 100), spacing: 2)
        makeObstacles(at: player.position.applying(CGAffineTransform(translationX: 0, y: 130)), amount: 250, size: CGSize(width: 50, height: 120), spacing: 2)
        makeObstacles(at: player.position.applying(CGAffineTransform(translationX: 3100, y: 300)), amount: 250, size: CGSize(width: 3000, height: 120), spacing: 1.1)
    }
    
    func makeObstacles(at origin: CGPoint, amount: Int, size: CGSize, spacing: CGFloat) {
        for i in 0...amount {
            let obstacleSize = CGSize(width: size.width + CGFloat(i), height: size.height + CGFloat(i))
            let obstaclePosition = CGPoint(x: origin.x + CGFloat(obstacleSize.width * CGFloat(i) * spacing), y: origin.y + CGFloat(obstacleSize.height))
            let obstacle = Obstacle(position: obstaclePosition, size: obstacleSize, isDynamic: true)
            obstacle.physicsBody!.density = 0.05
            addChild(obstacle)
        }
        
        for i in 0...amount {
            let obstacleSize = CGSize(width: 250, height: 10000)
            let obstaclePosition = CGPoint(x: origin.x + CGFloat(250 * CGFloat(i) * 10), y: 2500)
            let obstacle = Obstacle(position: obstaclePosition, size: obstacleSize, isDynamic: false)
            obstacle.physicsBody = nil
            obstacle.zPosition = -10
            obstacle.alpha = 0.2
            addChild(obstacle)
        }
    }
    
    func applyGravityMultipliers(to physicsBody: SKPhysicsBody) {
        return
        if physicsBody.velocity.dy < 0 {
            physicsBody.applyImpulse(CGVector(dx: 0, dy: physicsWorld.gravity.dy * (fallMultiplier - 1)))
        } else if physicsBody.velocity.dy > 0 && !touchDown {
            physicsBody.applyImpulse(CGVector(dx: 0, dy: mphysicsWorld.gravity.dy * (lowJumpMultiplier - 1)))
        }
    }
}

// MARK: Public helpers
extension GameScene {
    func addChaser(position: CGPoint, size: CGSize = CGSize(width: 60, height:  60)) {
        let chaser = Enemy.createChaser(position: position, size: size)
        let initalSpeed = chaser.moveSpeed * 0.8
        let randx = CGFloat.random(in: -initalSpeed..<initalSpeed)
        let randy = CGFloat.random(in: -initalSpeed..<initalSpeed)
        enemies.append(chaser)
        addChild(chaser)
        chaser.physicsBody!.applyImpulse(CGVector(dx: CGFloat(randx), dy: CGFloat(randy)))
    }
    
    func remove(deadEnemy: Enemy) {
        enemies.removeAll { enemy in
            deadEnemy == enemy
        }
    }
    
    func addBee(position: CGPoint) {
        let bee = Enemy.createBee(position: position)
        let initalSpeed = bee.moveSpeed * 0.8
        let randx = CGFloat.random(in: -initalSpeed..<initalSpeed)
        let randy = CGFloat.random(in: -initalSpeed..<initalSpeed)
        
        enemies.append(bee)
        addChild(bee)
        bee.physicsBody!.applyImpulse(CGVector(dx: CGFloat(randx), dy: CGFloat(randy)))
    }
}

// MARK: Collision detection
extension GameScene: SKPhysicsContactDelegate {
    func onContactBetween(projectile: SKNode, node: SKNode) {
        guard let projectile = projectile as? Projectile  else { return }
        if let node = node as? SKSpriteNode {
            node.run(SKAction.colorize(with: projectile.color, colorBlendFactor: 0.2, duration: 0.01))
            projectile.color = node.color
            projectile.run(SKAction.colorize(with: Style.PROJECTILE_COLOR, colorBlendFactor: 1, duration: 0.25))
            node.run(.sequence([.wait(forDuration: 0.025), .run {
                switch node.name {
                case "bee":
                    node.color = Style.BEE_COLOR
                case "enemy":
                    node.color = Style.CHASER_COLOR
                case "obstacle":
                    node.color = Style.OBSTACLE_COLOR
                case "flyerDrop":
                    node.color = Style.FLYER_COLOR
                default:
                    node.color = Style.PROJECTILE_COLOR
                }
            }]))
        } else {
            projectile.color = .systemPink
        }
        
        //    projectile.physicsBody!.contactTestBitMask = 0
        if let node = node as? Entity {
            node.damage()
        }
    }
    
    func onContactBetween(enemy: SKNode, node: SKNode) {
        if node.name == "flyerDrop" {
            
        }
    }
    
    func onContactBetween(bee: SKNode, node: SKNode) {
        if node.name != "player" { return }
        bee.run(SKAction.repeatForever(SKAction.sequence([SKAction.colorize(with: Style.CHASER_COLOR, colorBlendFactor: 0.5, duration: 0.1), SKAction.colorize(with: Style.BEE_COLOR, colorBlendFactor: 1, duration: 0.1)])))
        bee.run(SKAction.scale(to: 50, duration: 2), completion: {
            self.addChaser(position: bee.position)
            bee.removeFromParent()
        })
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        lightImpactFeedbackGenerator.prepare()
        mediumImpactFeedbackGenerator.prepare()
        heavyImpactFeedbackGenerator.prepare()
        guard let playerPhysicsBody = player.physicsBody else { return }
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        if nodeA.name == "projectile" {
            onContactBetween(projectile: nodeA, node: nodeB)
        } else if nodeB.name == "projectile" {
            onContactBetween(projectile: nodeB, node: nodeA)
        }
        
        if nodeA.name == "enemy" {
            onContactBetween(enemy: nodeA, node: nodeB)
        } else if nodeB.name == "enemy" {
            onContactBetween(enemy: nodeB, node: nodeA)
        }
        
        if nodeA.name == "bee" {
            onContactBetween(bee: nodeA, node: nodeB)
        } else if nodeB.name == "bee" {
            onContactBetween(bee: nodeB, node: nodeA)
        }
        
        let contactTestBitMask = contact.bodyA.contactTestBitMask | contact.bodyB.contactTestBitMask
        switch contactTestBitMask {
        case playerPhysicsBody.contactTestBitMask:
            player.isJumping = false
            
            let deltaVelocity = playerPhysicsBody.velocity - playerPreviousVelocity
            let speed = abs(deltaVelocity.dx) + abs(deltaVelocity.dy)
            
            if speed >= 50 && speed < 600 {
                lightImpactFeedbackGenerator.impactOccurred()
            } else if speed >= 600 && speed < 1000 {
                mediumImpactFeedbackGenerator.impactOccurred()
            } else if speed >= 1000 {
                heavyImpactFeedbackGenerator.impactOccurred()
            }
            
        default:
            return
        }
    }
}

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
  
  lazy var stateMachine: GKStateMachine = {
    let playState = PlayState(withGame: self)
    let pauseState = PauseState(withGame: self)
    return GKStateMachine(states: [playState, pauseState])
  }()
  
  
  // TODO: Fix enemies never being deleted after death
  var enemies = [Enemy]()
  var maxEnemies = 1
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
  
  var collisionSound = SKAction.playSoundFileNamed(GameConstants.CollisionSoundFileName, waitForCompletion: false)
  var tapSound = SKAction.playSoundFileNamed(GameConstants.TapSoundFileName, waitForCompletion: false)
  var damageSound = SKAction.playSoundFileNamed(GameConstants.shootSounds.LazerDamageFileName, waitForCompletion: false)
  
  override func didMove(to view: SKView) {
    super.didMove(to: view)
    if let scene = scene {
      scene.physicsWorld.gravity = .zero
    }
    setupScene()
  }
  
  override func update(_ currentTime: TimeInterval) {
    lastUpdateTimeInterval = currentTime
    stateMachine.update(deltaTime: currentTime)
    super.update(currentTime)
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else { return }
    if stateMachine.currentState is PauseState {
      stateMachine.enter(PlayState.self)
    }
    touchLocation = touch.location(in: cam)
      
    player.jump()
    
    // Get UI node that was touched.
    let touchedNodes = cam.nodes(at: touchLocation)
    for node in touchedNodes {
      if node.name == "restartButton" {
        let scene = GameScene(size: size)
        scene.scaleMode = scaleMode
        let animation = SKTransition.fade(withDuration: 0.2)
        view?.presentScene(scene, transition: animation)
      }
    }
    
    touchDown = true
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    touchDown = false
  }
  deinit{print("GameScene deinited")}
  
}

// MARK: Setup
private extension GameScene {
  func setupScene() {
    guard let scene = scene else { return }
    scene.backgroundColor = Style.BACKGROUND_COLOR
    let backgroundGrid = Factory.effects.createLightGrid(size: self.size * 2000, position: .zero, color: Style.PLAYER_COLOR)
    backgroundGrid.anchorPoint = CGPoint(x: 0.5, y: 0.5)
    backgroundGrid.zPosition = -12
    addChild(backgroundGrid)
    
    player = Player(size: CGSize(width: 40, height: 40))
    addChild(player)
    player.position = CGPoint(x: size.width / 2, y: size.height / 2)
    
    addChaser(position: CGPoint(x: player.position.x - 100, y: size.height / 2))
    yellowEnemy = addFlyer(position: player.position + CGPoint(xy: 1) * 2)
    
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
    stateMachine.enter(PauseState.self)
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
      guard let physicsBody = player.physicsBody else { return }
      physicsBody.applyImpulse(CGVector(dx: data.velocity.x * player.moveSpeed , dy: data.velocity.y * player.moveSpeed))
    }
    movePlayerStick.beginHandler = {
      self.player.isBoosting = true
    }
    cam.addChild(movePlayerStick)
    
    // Setup joystick to control player movement.
    shootPlayerStick.position = CGPoint(x: size.width / 2 - shootPlayerStick.radius * 2, y: -size.height / 2 + shootPlayerStick.radius * 1.7)
    shootPlayerStick.stick.color = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.5)
    shootPlayerStick.substrate.color = #colorLiteral(red: 0.6722276476, green: 0.6722276476, blue: 0.6722276476, alpha: 0.3)
    shootPlayerStick.trackingHandler = { [unowned self] data in
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
    makeObstacles(at: player.position.applying(CGAffineTransform(translationX: self.size.width, y: -self.size.height)), amount: 1000, size: CGSize(width: 200, height: 25), spacing: 400)
  }
  
  func makeObstacles(at origin: CGPoint, amount: Int, size: CGSize, spacing: CGFloat) {
    let distrX = CGFloat(amount) * spacing * 4
    let distrY = CGFloat(amount) * spacing / 8
    for _ in 0...amount {
      // misc blocks
      let miscBlockSize = size.height * 2
      var obstacleSize = CGSize(width: miscBlockSize + CGFloat.random(in: miscBlockSize...miscBlockSize*4), height: miscBlockSize + CGFloat.random(in: miscBlockSize...miscBlockSize*4))
      var obstaclePosition = CGPoint(x: origin.x + obstacleSize.width + CGFloat.random(in: -distrX*0.2...distrX), y: origin.y + obstacleSize.height + CGFloat.random(in: -distrY*0.2...distrY))
      var obstacle = Obstacle(position: obstaclePosition, size: obstacleSize, isDynamic: true)
      obstacle.physicsBody!.density = 0.001
      obstacle.alpha = 0.6
      
      addChild(obstacle)
      // long blocks
      obstacleSize = CGSize(width: size.width * 10 + CGFloat.random(in: size.width...size.width*2), height: size.height * 0.8 + CGFloat.random(in: size.height...size.height*2))
      obstaclePosition = CGPoint(x: origin.x + obstacleSize.width + CGFloat.random(in: -distrX...distrX), y: origin.y + CGFloat((obstacleSize.height + CGFloat.random(in: -distrY...distrY))))
      obstacle = Obstacle(position: obstaclePosition, size: obstacleSize, isDynamic: true)
      obstacle.physicsBody!.density = 0.001
      obstacle.alpha = 0.6
      addChild(obstacle)
        // background
//      obstacleSize = CGSize(width: 250, height: 1000000)
//      obstaclePosition = CGPoint(x: origin.x + CGFloat(500 * CGFloat(i) * 10), y: 2500)
//      obstacle = Obstacle(position: obstaclePosition, size: obstacleSize, isDynamic: false)
//      obstacle.physicsBody = nil
//      obstacle.zPosition = -10
//      obstacle.alpha = 0.2
//      addChild(obstacle)
    }
  }
  
  func applyGravityMultipliers(to physicsBody: SKPhysicsBody) {
    if physicsBody.velocity.dy < 0 {
      physicsBody.applyImpulse(CGVector(dx: physicsWorld.gravity.dx * (fallMultiplier - 1), dy: physicsWorld.gravity.dy * (fallMultiplier - 1)))
    } else if physicsBody.velocity.dy > 0 && !touchDown {
      physicsBody.applyImpulse(CGVector(dx: physicsWorld.gravity.dx * (lowJumpMultiplier - 1), dy: physicsWorld.gravity.dy * (lowJumpMultiplier - 1)))
    }
  }
}

// MARK: Public helpers
extension GameScene {
  func addChaser(position: CGPoint, size: CGSize = CGSize(width: 60, height:  60)) {
    let chaser = Enemy.createChaser(position: position, size: size, game: self)
    add(enemy: chaser)
  }
  
  func remove(deadEnemy: Enemy) {
    enemies.removeAll {
      deadEnemy.id == $0.id
    }
    
    if enemies.count <= 1 {
      self.maxEnemies += 1
    }
  }
  
  func add(enemy: Enemy) {
   enemies.append(enemy)
   addChild(enemy)
  }
  
  func addBee(position: CGPoint) {
    let bee = Enemy.createBee(position: position, game: self)
    add(enemy: bee)
  }
  
  func addFlyer(position: CGPoint) -> Enemy {
    let flyer = Enemy.createFlyer(position: position, game: self)
    add(enemy: flyer)
    return flyer
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
      node.run(.sequence([.wait(forDuration: 0.025), .run { [unowned self] in
        switch node.name {
        case "bee":
          node.color = Style.BEE_COLOR
          tapFeedback()
        case "enemy":
          node.color = Style.CHASER_COLOR
          tapFeedback()
        case "obstacle":
          node.color = Style.OBSTACLE_COLOR
        case "flyerDrop":
          node.color = Style.FLYER_COLOR
          tapFeedback()
        case "flyer":
          node.color = Style.FLYER_COLOR
        default:
          node.color = Style.PROJECTILE_COLOR
        }
        node.circleWaveImpact()
      }]))
    } else {
      projectile.color = .systemPink
    }
    //    projectile.physicsBody!.contactTestBitMask = 0
    if let node = node as? Entity {
      guard let healthComponent = node.component(ofType: HealthComponent.self) as? HealthComponent else { return }
      healthComponent.damage()
      run(damageSound)
    }
  }
  
  func onContactBetween(enemy: SKNode, node: SKNode) {
    if node.name == "flyerDrop" {
      
    }
  }
  
  func onContactBetween(bee: SKNode, node: SKNode) {
    if node.name != "player" { return }
    guard let bee = bee as? SKSpriteNode else { return }
    bee.run(SKAction.repeatForever(SKAction.sequence([SKAction.colorize(with: Style.CHASER_COLOR, colorBlendFactor: 0.5, duration: 0.1), SKAction.colorize(with: Style.BEE_COLOR, colorBlendFactor: 1, duration: 0.1), SKAction.run {
      bee.circleWaveImpact()
    }])))
    bee.run(SKAction.scale(to: 50, duration: 2), completion: {
      self.addChaser(position: bee.position)
      bee.removeFromParent()
    })
  }
  
  
  func didBegin(_ contact: SKPhysicsContact) {
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
      
      let deltaVelocity = playerPhysicsBody.velocity.distance(to: playerPreviousVelocity)
      let speed = deltaVelocity.magnitude
      if speed > 600 {
        run(collisionSound)
        tapFeedback(intensity: 1)
      } else if speed < 500 {
        run(tapSound)
        tapFeedback(intensity: 2)
      }
    default:
      return
    }
  }
}

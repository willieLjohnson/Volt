//
//  GameScene.swift
//  Volt
//
//  Created by Willie Johnson on 3/8/18.
//  Copyright © 2018 Willie Johnson. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFAudio

class GameScene: SKScene {
  var currentChunk: Bit?
  var player: Player?
  var yellowEnemy: Enemy?
  
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
  var leftStickPosition: CGPoint {
    CGPoint(x: -size.width / 2 + movePlayerStick.radius * 2, y: -size.height / 2 + movePlayerStick.radius * 1.7)
  }
  
  let shootPlayerStick = AnalogJoystick(diameters: (135, 100))
  var rightStickPosition: CGPoint {
    CGPoint(x: size.width / 2 - shootPlayerStick.radius * 2, y: -size.height / 2 + shootPlayerStick.radius * 1.7)
  }
  
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
    do {
      let audioSession = AVAudioSession.sharedInstance()
      try audioSession.setCategory(
        AVAudioSession.Category.playback,
        options: AVAudioSession.CategoryOptions.mixWithOthers
      )
    } catch {
      print("Can't set audio session to mixWithOthers")
    }
    
    if let scene = scene {
      scene.physicsWorld.gravity = .zero
      scene.view!.isMultipleTouchEnabled = true
    }
    setupScene()
  }
  
  func updatePlayer() {
    guard let player = self.player else { return }
    playerPreviousVelocity = player.physicsBody!.velocity
    timeLabel.text = String(format: "%.2f", player.physicsBody!.velocity.magnitude/100)
  }
  
  override func update(_ currentTime: TimeInterval) {
    updatePlayer()
    lastUpdateTimeInterval = currentTime
    stateMachine.update(deltaTime: currentTime)
    super.update(currentTime)
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    for touch in touches {
      if stateMachine.currentState is PauseState {
        stateMachine.enter(PlayState.self)
      }
      touchLocation = touch.location(in: cam)
      
      if touchLocation.x < -size.width * 0.05 {
        movePlayerStick.position = touchLocation
        movePlayerStick.forceBegan(touches, with: event)
      } else if touchLocation.x > size.width * 0.05 {
        shootPlayerStick.position = touchLocation
        shootPlayerStick.forceBegan(touches, with: event)
      }
      
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
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    for touch in touches {
     let touchLocation = touch.location(in: cam)
      print((touchLocation, size.width * 0.5))
      if touchLocation.x < -size.width * 0.05 {
        movePlayerStick.touchesMoved(touches, with: event)
        if movePlayerStick.position.distance(to: touchLocation) > movePlayerStick.maxDistantion * 2 {
          movePlayerStick.position = touchLocation
        }
      } else if touchLocation.x > size.width * 0.05 {
        shootPlayerStick.touchesMoved(touches, with: event)
        if shootPlayerStick.position.distance(to: touchLocation) > shootPlayerStick.maxDistantion * 2 {
          shootPlayerStick.position = touchLocation
        }
      }
    }
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    
    guard let touch = touches.first else { return }
    let touchLocation = touch.location(in: cam)
    touchDown = false
    
    if touchLocation.x < 0 {
        movePlayerStick.touchesEnded(touches, with: event)
        movePlayerStick.position = leftStickPosition
    } else {
        shootPlayerStick.touchesEnded(touches, with: event)
        shootPlayerStick.position = rightStickPosition
    }
  }
  deinit{print("GameScene deinited")}
  
}

// MARK: Setup
private extension GameScene {
  func setupScene() {
    guard let scene = scene else { return }
    scene.backgroundColor = Theme.background
    
    currentChunk = Bit()
    let chunkBoard = Factory.effects.createBoard(size: self.size * 1000, position: .zero, colors: Pair<SKColor>(Theme.foreground.withAlphaComponent(0.8), Theme.foreground))
    chunkBoard.anchorPoint = CGPoint(x: 0.5, y: 0.5)
    chunkBoard.zPosition = -12
    currentChunk!.addChild(chunkBoard)
    addChild(currentChunk!)
    
    player = Player(size: CGSize(width: 2, height: 2))
    player!.add(component: MoveComponent(entity: player, moveSpeed: 0.001))
    player!.game = self
    addChild(player!)
    addChaser(position: CGPoint(x: player!.size.width / 2, y: size.height / 2))
    yellowEnemy = addFlyer(position: player!.position + CGPoint.one * size.height * 0.2)
    
    populateWorld()
    
    cam = SKCameraNode()
    cam.zPosition = 1000
    cam.setScale(2)
    setupUI()
    physicsWorld.contactDelegate = self
    self.camera = cam
    addChild(cam!)
    let timeAction = SKAction.run { [weak self] in
      guard let self = self else { return }
      self.time += Double(self.physicsWorld.speed / 100)
      self.timeLabel.text = String(format: "%.2f", self.time)
    }
    
//    run(SKAction.repeatForever(SKAction.sequence([timeAction, .wait(forDuration: 0.01)])))
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
    cam.setScale(1)
    
    // Setup joystick to control player movement.
    movePlayerStick.position = leftStickPosition
    movePlayerStick.stick.color = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.5)
    movePlayerStick.substrate.color = #colorLiteral(red: 0.6722276476, green: 0.6722276476, blue: 0.6722276476, alpha: 0.3)
    movePlayerStick.name = "movePlayerStick"
    movePlayerStick.trackingHandler = { [weak self] data in
      self?.player?.dash(CGVector(data.velocity))
    }
    movePlayerStick.beginHandler = { [weak self] in
      self?.player?.isBoosting = true
    }
    cam.addChild(movePlayerStick)
    
    // Setup joystick to control player movement.
    shootPlayerStick.position = rightStickPosition
    shootPlayerStick.name = "shootPlayerStick"
    shootPlayerStick.stick.color = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.5)
    shootPlayerStick.substrate.color = #colorLiteral(red: 0.6722276476, green: 0.6722276476, blue: 0.6722276476, alpha: 0.3)
    shootPlayerStick.trackingHandler = { [weak self] data in
      self?.player?.shoot(at: CGVector(dx: data.velocity.x, dy: data.velocity.y))
    }
    cam.addChild(shootPlayerStick)
  }
}

// MARK: Scene Environment
private extension GameScene {
  func createBackground() {
    for i in 0...1000 {
      let node = SKSpriteNode(color: Theme.obstacle.with(hue: nil, saturation: 0.1, brightness: 0.1), size: CGSize(width: size.width * 0.9, height: size.height * 0.95))
      node.position = CGPoint(x: CGFloat(i) * node.frame.width + 50, y: node.frame.height)
      addChild(node)
    }

  }
  
  
  func populateWorld() {
    makeObstacles(at: .zero, amount: 1000, size: CGSize(width: 2, height: 2), spacing: 10)
  }
  
  func makeObstacles(at origin: CGPoint, amount: Int, size: CGSize, spacing: CGFloat) {
    let distrX = CGFloat(amount) * spacing * 4
    let distrY = CGFloat(amount) * spacing / 8
    for _ in 0...amount {
      // misc blocks
      let miscBlockSize = size.height * 2
      var obstacleSize = CGSize(width: miscBlockSize + CGFloat.random(in: miscBlockSize...miscBlockSize*4), height: miscBlockSize + CGFloat.random(in: miscBlockSize...miscBlockSize*4))
      var obstaclePosition = CGPoint(x: origin.x + obstacleSize.width + CGFloat.random(in: -distrX*0.2...distrX), y: origin.y + obstacleSize.height + CGFloat.random(in: -distrY...distrY * 0.5))
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
  func addChaser(position: CGPoint, size: CGSize = CGSize(width: 4, height:  4)) {
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
      projectile.run(SKAction.colorize(with: Theme.projectile, colorBlendFactor: 1, duration: 0.25))
      node.run(.sequence([.wait(forDuration: 0.025), .run { [unowned self] in
        switch node.name {
        case "bee":
          node.color = Theme.bee
          tapFeedback()
        case "enemy":
          node.color = Theme.chaser
          tapFeedback()
        case "obstacle":
          node.color = Theme.obstacle
        case "flyerDrop":
          node.color = Theme.flyer
          tapFeedback()
        case "flyer":
          node.color = Theme.flyer
        default:
          node.color = Theme.projectile
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
    bee.run(SKAction.repeatForever(SKAction.sequence([SKAction.colorize(with: Theme.chaser, colorBlendFactor: 0.5, duration: 0.1), SKAction.colorize(with: Theme.bee, colorBlendFactor: 1, duration: 0.1), SKAction.run {
      bee.circleWaveImpact()
    }])))
    bee.run(SKAction.scale(to: 50, duration: 2), completion: {
      self.addChaser(position: bee.position)
      bee.removeFromParent()
    })
  }
  
  
  func didBegin(_ contact: SKPhysicsContact) {
    guard let playerPhysicsBody = player?.physicsBody else { return }
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

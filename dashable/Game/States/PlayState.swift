import GameplayKit

class PlayState: GameState {
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        switch stateClass {
        case is PauseState.Type:
            return true
          
        default:
            return false
        }
    }
    
    override func didEnter(from previousState: GKState?) {
      game.physicsWorld.speed = 1
      game.speed = 1
      game.player.alpha = 1
      for enemy in game.enemies {
        enemy.alpha = 1
      }
    }
    
    override func update(deltaTime: TimeInterval) {
      guard let cam = game.cam else { return }
      guard let player = game.player else { return }
      player.update(game, deltaTime: deltaTime)
      for enemy in game.enemies {
        enemy.update(deltaTime)
      }
      
      // Get player bodies
      guard let playerPhysicsBody = player.physicsBody else { return }
      // t = t*t*t * (t * (6f*t - 15f) + 10f)
      // t = t*t * (3f - 2f*t)
      
      let playerVelocity = playerPhysicsBody.velocity
      
      let velocityLerp = playerVelocity / 360 * 0.01
      let speedLerp = playerVelocity.magnitude / 360 * 0.01
      let ispeedLerp = 1 - speedLerp
      let ivelocityLerp = CGVector.one - velocityLerp
      
      let scale = (0.1 + speedLerp) * 2
      let duration = 0.01 + 0.01 * ispeedLerp
      
      let xoffsetMax = game.size.width * 2
      let yoffsetMax = game.size.height * 2
      
      let offsetFactor = CGPoint(x: xoffsetMax * velocityLerp.dx, y: yoffsetMax * velocityLerp.dy)
      cam.setScale(scale.clamped(to: 0.1...2))
//      print((velocityLerp, offsetFactor, scale, duration))
//      print(cam.xScale)
      cam.run(.move(to: CGPoint(x: player.position.x + offsetFactor.x, y: player.position.y + offsetFactor.y), duration: duration))
      
      game.playerPreviousVelocity = playerPhysicsBody.velocity
    }
    
}

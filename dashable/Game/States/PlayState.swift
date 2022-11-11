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
        enemy.update(deltaTime: deltaTime)
      }
      
      // Get player bodies
      guard let playerPhysicsBody = player.physicsBody else { return }
      
      let xOffsetMax = game.size.width * 2
      let yOffsetMax = game.size.height * 2
      // Move cam to player
      let duration = TimeInterval(0.4 * pow(0.9, abs(playerPhysicsBody.velocity.magnitude / 100) - 1) + 0.05)
      let xOffsetExpo = CGFloat(0.4 * pow(0.9, -abs(playerPhysicsBody.velocity.dx) / 100 - 1) - 0.04)
      let yOffsetExpo = CGFloat(0.4 * pow(0.9, -abs(playerPhysicsBody.velocity.dy) / 100 - 1) - 0.04)
      let yScaleExpo = CGFloat(0.01 * pow(0.9, -abs(playerPhysicsBody.velocity.dy) / 100 - 1) + 3.16)
      let xScaleExpo = CGFloat(0.01 * pow(0.9, -abs(playerPhysicsBody.velocity.dx) / 100 - 1) + 3.16)
      let xOffset = xOffsetExpo.clamped(to: -xOffsetMax...xOffsetMax) * (playerPhysicsBody.velocity.dx > 0 ? 1 : -1)
      let yOffset = yOffsetExpo.clamped(to: -yOffsetMax...yOffsetMax) * (playerPhysicsBody.velocity.dy > 0 ? 1 : -1)
      let scaleExpo = max(xScaleExpo, yScaleExpo)
      let scale = scaleExpo.clamped(to: 5...10)
      cam.setScale(scale)
      cam.run(.move(to: CGPoint(x: player.position.x + xOffset, y: player.position.y + yOffset), duration: duration))
      
      game.playerPreviousVelocity = playerPhysicsBody.velocity
    }
    
}

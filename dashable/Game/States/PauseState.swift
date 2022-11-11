import GameplayKit

class PauseState: GameState {
  override func isValidNextState(_ stateClass: AnyClass) -> Bool {
    switch stateClass {
    case is PlayState.Type:
      return true
    default:
      return false
    }
  }
  
  override func didEnter(from previousState: GKState?) {
    game.physicsWorld.speed = 0
    game.speed = 0
    game.player.alpha = 0.2
    for enemy in game.enemies {
      enemy.alpha = 0.2
    }
  }
}

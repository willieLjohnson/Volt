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
    let pauseNode = SKShapeNode(rectOf: game.size * 2)
    pauseNode.fillColor = Theme.background.withAlphaComponent(0.8)
    pauseNode.name = "pauseNode"
    game.cam.addChild(pauseNode)
  }
}

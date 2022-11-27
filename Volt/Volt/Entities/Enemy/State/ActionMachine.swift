//
//  EnemyLogic.swift
//  Volt
//
//  Created by Willie Johnson on 3/22/18.
//  Copyright © 2018 Willie Johnson. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit


enum Result: CustomStringConvertible {
  case Init, Looped, Completed, Warned(String = ""), Failed(String = "")
  func debug(_ args: Any...) {
    print([self.description : args])
  }
  
  var description: String {
    switch self {
    case .Completed: return "Completed"
    case .Looped: return "Looped"
    case .Warned(let x): return "WARN: \(x)"
    case .Failed(let x): return "ERROR: \(x)"
    default:
        return "Init"
    }
  }
}

enum Status: CustomStringConvertible {
  case Init, Starting, Updating
  func debug(_ args: Any...) {
    print([self.description : args])
  }
  
  var description: String {
    switch self {
    case .Starting: return "Starting"
    case .Updating: return "Updating"
    default: return "Init"
    }
  }
}

protocol Transitioning: Updatable {
  func transition(forClass transitionClass: Transition.Type) -> Transition?
  mutating func add(_ transition: Transition) -> Bool
  mutating func add(transitions: Set<Transition>) -> Bool
  mutating func remove(_ transitionClass: Transition.Type) -> Transition?
  mutating func from(_ transition: Transition) -> Result
  mutating func present(_ transitionClass: Transition.Type) -> Result
  mutating func presenting(_ transitionClass: Transition.Type) -> Self
  mutating func can(present transition: Transition.Type) -> Bool
  mutating func set(_ status: Status)
  mutating func done(_ result: Result)
  mutating func loop()
  mutating func reset()
}

extension Transitioning {
  func from(_ transition: Transition) -> Result {
    .Init
  }
  func can(present transition: Transition.Type) -> Bool {
    true
  }
}

class Transition: Transitioning {
  var id: UUID = .init()
  var machine: TransitionMachine?
  var status: Status = .Init
  var counter: Int = 0
}

extension Transition {
  func set(_ status: Status) {
    self.status = status
  }
  
  func start() {
    set(.Starting)
  }
  
  func loop() {
    start()
    self.counter += 1
  }
  
  func reset() {
    self.counter = 0
    self.set(.Init)
  }

  func done(_ result: Result) {
    switch result {
    case .Completed:
      set(.Init)
    case .Looped:
      self.loop()
    case .Warned(_):
      status.debug(id.uuidString.suffix(4))
    case .Failed(_):
      status.debug(id.uuidString.suffix(4))
    default:
      return
    }
  }

}

extension Transitioning where Self: Transition {
  func transition(forClass transitionClass: Transition.Type) -> Transition? {
    self.machine != nil ? self.machine!.transition(forClass: transitionClass) : nil
  }
  
  func add(_ transition: Transition) -> Bool {
    self.machine != nil ? self.machine!.add(transition) : false
  }
  
  func add(transitions: Set<Transition>) -> Bool {
    self.machine != nil ? self.machine!.add(transitions: transitions) : false
  }
  
  func remove(_ transitionClass: Transition.Type) -> Transition? {
    self.machine != nil ? self.machine!.remove(transitionClass) : nil
  }
  
  func present(_ transitionClass: Transition.Type) -> Result {
    self.machine != nil ? self.machine!.present(transitionClass) : .Failed("No transition machine")
  }
  
  func presenting(_ transitionClass: Transition.Type) -> Self {
    guard machine != nil else { return self }
    _ = machine!.present(transitionClass)
    return self
  }
  
  
  
  func update(_ deltaTime: TimeInterval?) {
    
  }
  
}

extension Transitioning where Self: TransitionMachine {
  func transition(forClass transitionClass: Transition.Type) -> Transition? {
    self.transitions.first {
      type(of: $0) == transitionClass
    }
  }
  
  func add(_ transition: Transition) -> Bool {
    self.transitions.insert(transition).inserted
  }
  
  
  func add(transitions: Set<Transition>) -> Bool {
    var allAdded = true
    for transition in transitions {
      allAdded = allAdded && self.transitions.insert(transition).inserted
    }
    return allAdded
  }
  
  func remove(_ transitionClass: Transition.Type) -> Transition? {
    guard let transition = transition(forClass: transitionClass) else { return nil }
    return self.transitions.remove(transition)
  }
  
  func present(_ transitionClass: Transition.Type) -> Result {
    guard let transition = transition(forClass: transitionClass) else { return .Failed("\(transitionClass) not included as a transition.")}
    self.currentTransition = transition
    return transition.from(self)
  }
  
  func presenting(_ transitionClass: Transition.Type) -> Self {
    _ = self.present(transitionClass)
    return self
  }
  
  func update(_ deltaTime: TimeInterval?) {
    self.currentTransition?.update(deltaTime)
  }
}

class TransitionMachine: Transition {
  var currentTransition: Transition? = nil
  var transitions: Set<Transition> = []
  init(transitions: Set<Transition>? = nil) {
    super.init()
    _ = transitions != nil ? self.add(transitions: transitions!) : false
  }
}

class State: Transition {
  static var none: State {
    State()
  }
}


class StateMachine: TransitionMachine {
  func enter(_ stateClass: State.Type) -> Result {
    guard let state = state(forClass: stateClass) else { return .Failed("State not included") }
    self.currentTransition = state
    return state.from(self)
  }
  
  func entering(_ stateClass: State.Type) -> Self {
    _ = self.enter(stateClass)
    return self
  }
  
  func state(forClass stateClass: State.Type) -> State? {
    self.transition(forClass: stateClass) as? State
  }
  
  func add(state: State) -> Bool  {
    self.add(state)
  }
  func remove(stateClass: State.Type) -> State?  {
    guard let state = state(forClass: stateClass) else { return nil }
    return self.transitions.remove(state) as? State
  }
  
  func update(_ deltaTime: TimeInterval?) {
    currentTransition?.update(deltaTime)
  }
}

protocol Agent: Composable {}

extension Entity: Agent {}
extension Bit: Agent {}

class Action<AgentType: Agent>: ActionMachine<AgentType>, CustomStringConvertible {
  var description: String {
    return [id.last4(): [status, counter, [agent?.id.last4() : agent?.components]]].description
  }
  
  init(agent: AgentType, actions: Set<Action<AgentType>>? = nil) {
    super.init(agent: agent, states: actions)
  }
}

class ActionMachine<AgentType: Agent>: StateMachine {
  var agent: AgentType?
  var currentAction: Action<AgentType>? {
    self.currentTransition as? Action<AgentType>
  }
  init(agent: AgentType, states: Set<Action<AgentType>>?) {
    self.agent = agent
    super.init(transitions: states)
  }
  
  func execute(_ actionClass: Action<AgentType>.Type) -> Result {
    guard let action = self.action(forClass: actionClass) else { return .Failed("Action not included") }
    self.currentTransition = action
    return action.from(action: self)
  }
  
  func from(action: ActionMachine<AgentType>) -> Result {
    .Init
  }

  func executing(_ actionClass: Action<AgentType>.Type) -> Self {
    _ = self.execute(actionClass)
    return self
  }
  
  func action<ActionType>(forClass actionClass: ActionType.Type) -> ActionType? where ActionType : Action<AgentType> {
    self.transition(forClass: actionClass) as? ActionType
  }
  
  func add<StateType>(action: StateType) -> Bool where StateType : State {
    self.add(action)
  }
  func remove<ActionType>(actionClass: ActionType.Type) -> ActionType? where ActionType : Action<AgentType> {
    guard let action = action(forClass: actionClass) else { return nil }
    return self.transitions.remove(action) as? ActionType
  }
  
  override func update(_ deltaTime: TimeInterval?) {
    self.currentAction?.update(deltaTime)
  }
}

typealias EnemyAction = Action<Enemy>

//struct EnemyMachineConstants {
//  /// Attempts to get ahead and stop the target by growing in size on blocking their way.
//  static var chaserLogic: LogicHandler = { logic, enemy in
//    guard let game = enemy.game else {return}
//    guard let moveComponent = enemy.component(ofType: MoveComponent.self) as? MoveComponent else {return}
//    guard let targetComponent = enemy.component(ofType: LocusComponent.self) as? TargetComponent else {return}
//
////    if (targetComponent.targetIsAttackable) {
////      logic.enter(AttackState.self)
////    }
//  }
//
//  /// Flies above and ehead of the target and drops obstacles.
//  static var flyerLogic: LogicHandler = { logic, flyer in
//    guard let game = flyer.game else {return}
//
//    guard let moveComponent = flyer.component(ofType: MoveComponent.self) as? MoveComponent else {return}
//    guard let weaponComponent = flyer.component(ofType: WeaponComponent.self) as? WeaponComponent else {return}
//    guard let targetComponent = flyer.component(ofType: TargetComponent.self) as? TargetComponent else {return}
//
//    guard let physicsBody = flyer.physicsBody else {return}
//    guard let target = targetComponent.target else {return}
//    guard let targetPhysicsBody = target.physicsBody else {return}
//
//    let positionDifferenceTotarget = Useful.differenceBetween(flyer, and: target)
//
//    let isNeartargetX = abs(positionDifferenceTotarget.x) < 20
//    let isNeartargetY = abs(positionDifferenceTotarget.y) < 20
//    let isTooCloseTotargetX = abs(positionDifferenceTotarget.x) < 10
//    let isTooCloseTotargetY = abs(positionDifferenceTotarget.y) < 10
//    let isFarFromtargetX = abs(positionDifferenceTotarget.x) > 30
//    let isFarFromtargetY = abs(positionDifferenceTotarget.y) > 30
//    let isVeryFar = CGVector(dx: positionDifferenceTotarget.x, dy: positionDifferenceTotarget.y).magnitude > 40
//
//    let isFarFromtarget = isFarFromtargetX || isFarFromtargetY
//    let isNeartarget = isNeartargetX && isNeartargetY
//    let isTooCloseTotarget = isTooCloseTotargetX && isTooCloseTotargetY
//
//    // Calculate forces to apply.
//    let angle = atan2(positionDifferenceTotarget.y, positionDifferenceTotarget.x)
//    let moveSpeed: CGFloat = moveComponent.moveSpeed
//
//    if !flyer.isAbilityActionRunning && !isVeryFar {
//
//    }
//
//    // Only run if there is no action(dropObstacle) already running
//    let shouldDropObstacle = !flyer.isAbilityActionRunning && weaponComponent.canShoot && !isFarFromtarget
//
//    guard shouldDropObstacle else { return }
//    // Create an obstacle and launch it towards the target.
//    flyer.isAbilityActionRunning = true
//
//    weaponComponent.shoot()
//
//    let finishAbilityAction = SKAction.run {
//      flyer.isAbilityActionRunning = false
//    }
//
//    let dropObstacle = SKAction.run {
//      let randWidthModifier = GKRandomSource.sharedRandom().nextInt(upperBound: 2)
//      let randHeightModifier = GKRandomSource.sharedRandom().nextInt(upperBound: 5)
//      let randVelocityModifier = CGFloat.random(in: 0...1)
//
//      let obstacleSize = CGSize(width: 4 + randWidthModifier, height: 4 + randHeightModifier)
//      let obstaclePosition = CGPoint(x: flyer.position.x, y: flyer.position.y - obstacleSize.height)
//
//      var obstacle = Obstacle(position: obstaclePosition, size: obstacleSize)
//
//      obstacle.addComponent(component: MoveComponent(entity: obstacle, moveSpeed: 0.01))
//      obstacle.physicsBody!.collisionBitMask = targetPhysicsBody.categoryBitMask | PhysicsCategory.enemy | PhysicsCategory.obstacles
//      obstacle.color = Style.FLYER_COLOR
//      obstacle.name = "flyerDrop"
//      game.addChild(obstacle)
//
//      obstacle.run(SKAction.repeatForever(SKAction.sequence([SKAction.colorize(with: Style.CHASER_COLOR, colorBlendFactor: 1, duration: 0.1), SKAction.colorize(with: Style.OBSTACLE_COLOR, colorBlendFactor: 1, duration: 0.1)])))
//      obstacle.run(SKAction.scale(to: 3, duration: 5), completion: {
//        obstacle.die()
//        game.addChaser(position: obstacle.position)
//      })
//      MoveComponent.component(from: obstacle).set(velocity: targetPhysicsBody.velocity)
//      MoveComponent.component(from: obstacle).dashTo(other: target)
//    }
//
//    flyer.run(.scale(to: 2, duration: 2)) {
//      flyer.run(.sequence([dropObstacle, .scale(to: 1, duration: 0.2), finishAbilityAction, .wait(forDuration: 2)]))
//    }
//  }
//}

//
//  EnemyLogic.swift
//  dashable
//
//  Created by Willie Johnson on 3/22/18.
//  Copyright © 2018 Willie Johnson. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class Logic: GKStateMachine {}
extension Logic {
  func entered(_ state: AnyClass) -> Self {
    self.enter(state)
    return self
  }
}


class EnemyLogic: Logic {
  let enemy: Enemy
  
  init(enemy: Enemy, states: [GKState]) {
    self.enemy = enemy
    super.init(states: states)
  }
}

//TODO: Refactor code and clean up for easier read
struct EnemyLogicConstants {
  /// Attempts to get ahead and stop the target by growing in size on blocking their way.
  static var chaserLogic: LogicHandler = { logic, enemy in
    guard let game = enemy.game else {return}
    
    guard let moveComponent = enemy.component(ofType: MoveComponent.self) as? MoveComponent else {return}
    guard let targetComponent = enemy.component(ofType: TargetComponent.self) as? TargetComponent else {return}
    
    guard let target = targetComponent.target else { return }
    
    let moveSpeed: CGFloat = moveComponent.moveSpeed
    // Grab physics bodies.
    guard let physicsBody = enemy.physicsBody else { return }
    guard let targetPhysicsBody = target.physicsBody else { return }

    // Distance between the enemy and the target as CGPoint.
    // The velocity of the enemy before any action is taken.
    let enemyVelocity = physicsBody.velocity
    let targetVelocity = targetPhysicsBody.velocity
    let velocityDifference = targetVelocity.distance(to: enemyVelocity)
    
    let distanceTotarget = target.position.distance(to: enemy.position)
    let areMovingInTheSameDirection = enemyVelocity.dot(targetVelocity) > 0

    // Analyze target.
    let isInAttackRange = distanceTotarget <= 500
    let isNeartarget = distanceTotarget <= 1000
    let isFarFromtarget = distanceTotarget > 5000
    let isVeryFar = distanceTotarget > 10000

    let isAlignedWithtarget = isNeartarget && areMovingInTheSameDirection
    
    // Analyze self.z
    let hasStopped = enemyVelocity.magnitude <= 800
    let isEnemyTooFast = velocityDifference > 5000
    let thinkstargetTooFast = velocityDifference < 2000

    // Move towards target.
    if isVeryFar && velocityDifference < 4000 {
      moveComponent.moveSpeed = moveComponent.getBaseMoveSpeed() * 10 * (2000/distanceTotarget)
    } else {
      moveComponent.moveSpeed = moveComponent.getBaseMoveSpeed() * (distanceTotarget/500)
    }
    
    if isInAttackRange {
      logic.enter(AttackState.self)
    } else {
    }
    moveComponent.follow(other: target)
  }

  /// Flies above and ehead of the target and drops obstacles.
  static var flyerLogic: LogicHandler = { logic, flyer in
    guard let game = flyer.game else {return}
    
    guard let moveComponent = flyer.component(ofType: MoveComponent.self) as? MoveComponent else {return}
    guard let weaponComponent = flyer.component(ofType: WeaponComponent.self) as? WeaponComponent else {return}
    guard let targetComponent = flyer.component(ofType: TargetComponent.self) as? TargetComponent else {return}
      
    guard let physicsBody = flyer.physicsBody else {return}
    guard let target = targetComponent.target else {return}
    guard let targetPhysicsBody = target.physicsBody else {return}
    
    let positionDifferenceTotarget = Useful.differenceBetween(flyer, and: target)
    
    let isNeartargetX = abs(positionDifferenceTotarget.x) < 1000
    let isNeartargetY = abs(positionDifferenceTotarget.y) < 1000
    let isTooCloseTotargetX = abs(positionDifferenceTotarget.x) < 800
    let isTooCloseTotargetY = abs(positionDifferenceTotarget.y) < 800
    let isFarFromtargetX = abs(positionDifferenceTotarget.x) > 2000
    let isFarFromtargetY = abs(positionDifferenceTotarget.y) > 2000
    let isVeryFar = CGVector(dx: positionDifferenceTotarget.x, dy: positionDifferenceTotarget.y).magnitude > 2000
    
    let isFarFromtarget = isFarFromtargetX || isFarFromtargetY
    let isNeartarget = isNeartargetX && isNeartargetY
    let isTooCloseTotarget = isTooCloseTotargetX && isTooCloseTotargetY
    
    // Calculate forces to apply.
    let angle = atan2(positionDifferenceTotarget.y, positionDifferenceTotarget.x)
    let moveSpeed: CGFloat = moveComponent.moveSpeed
    
    let vx: CGFloat = cos(angle) * moveSpeed * (isTooCloseTotargetX ? -10 : 1)
    let vy: CGFloat = sin(angle) * moveSpeed *  (isTooCloseTotargetY ? -10 : 1)
    
    if !flyer.isAbilityActionRunning && !isVeryFar {
      if isNeartarget && !isTooCloseTotarget {
        moveComponent.match(velocity: target.physicsBody!.velocity * 0.3)
        flyer.run(.scale(to: 2, duration: 0.5))
      }
      else if isFarFromtarget {
        flyer.run(.scale(to: 0.1, duration: 0.5))
        moveComponent.match(velocity: target.physicsBody!.velocity * 1.1)
      }
      else if !isFarFromtarget && !isNeartarget {
        flyer.run(.scale(to: 1, duration: 0.1))
        moveComponent.match(velocity: target.physicsBody!.velocity * 0.4)
      }
    } else if (isVeryFar) {
        moveComponent.moveSpeed = moveComponent.getBaseMoveSpeed() * 10
        moveComponent.impulseTowards(point: positionDifferenceTotarget)
        moveComponent.moveSpeed = moveComponent.getBaseMoveSpeed()
    } else {
      moveComponent.match(velocity: target.physicsBody!.velocity * 0.7)
    }
    // Only run if there is no action(dropObstacle) already running
    let shouldDropObstacle = !flyer.isAbilityActionRunning && weaponComponent.canShoot && !isFarFromtarget
  
    guard shouldDropObstacle else { return }
    // Create an obstacle and launch it towards the target.
    flyer.isAbilityActionRunning = true
    
    weaponComponent.shoot()

    let finishAbilityAction = SKAction.run {
      flyer.isAbilityActionRunning = false
    }
        
    let dropObstacle = SKAction.run {
      let randWidthModifier = GKRandomSource.sharedRandom().nextInt(upperBound: 40)
      let randHeightModifier = GKRandomSource.sharedRandom().nextInt(upperBound: 20)
      let randVelocityModifier = CGFloat.random(in: 0...1)
      
      let obstacleSize = CGSize(width: 80 + randWidthModifier, height: 80 + randHeightModifier)
      let obstaclePosition = CGPoint(x: flyer.position.x, y: flyer.position.y - obstacleSize.height)
      
      let obstacle = Obstacle(position: obstaclePosition, size: obstacleSize)
      
      obstacle.addComponent(component: MoveComponent(entity: obstacle, moveSpeed: 4000))
      obstacle.physicsBody!.collisionBitMask = targetPhysicsBody.categoryBitMask | PhysicsCategory.enemy | PhysicsCategory.obstacles
      obstacle.color = Style.FLYER_COLOR
      obstacle.name = "flyerDrop"
      game.addChild(obstacle)
      
      obstacle.run(SKAction.repeatForever(SKAction.sequence([SKAction.colorize(with: Style.CHASER_COLOR, colorBlendFactor: 1, duration: 0.1), SKAction.colorize(with: Style.OBSTACLE_COLOR, colorBlendFactor: 1, duration: 0.1)])))
      obstacle.run(SKAction.scale(to: 5, duration: 5), completion: {
        obstacle.die()
        game.addChaser(position: obstacle.position)
      })
      MoveComponent.component(from: obstacle).match(velocity: targetPhysicsBody.velocity)
      MoveComponent.component(from: obstacle).follow(other: target)
    }


    flyer.run(.scale(to: 10, duration: 4)) {
      flyer.run(.sequence([dropObstacle, .scale(to: 1, duration: 0.2), finishAbilityAction, .wait(forDuration: 2)]))
    }
  }
}

//
//  TargetComponent.swift
//  dashable
//
//  Created by Willie Liwa Johnson on 11/10/22.
//  Copyright © 2022 Willie Johnson. All rights reserved.
//

import Foundation

class TargetComponent: Component {
  var target: Entity? {
    willSet {
      guard newValue != nil else { return }
      targetFirstPosition = newValue!.position
    }
    didSet {
      guard target != nil else { return }
      targetFirstPosition = target!.position
    }
  }
  var targetFirstPosition: CGPoint = .zero
  var targetLastPosition: CGPoint = .zero
  
  init(entity: Entity? = nil, target: Entity?) {
    self.target = target
    super.init(entity: entity)
  }
  
  override func update(_ deltaTime: TimeInterval?) {
    guard let target = target else { return }
    targetLastPosition = target.position
  }
}

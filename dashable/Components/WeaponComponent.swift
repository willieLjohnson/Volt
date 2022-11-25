//
//  WeaponComponent.swift
//  dashable
//
//  Created by Willie Liwa Johnson on 11/8/22.
//  Copyright © 2022 Willie Johnson. All rights reserved.
//

import Foundation

class WeaponComponent: Component {
  var attackRange: CGFloat = 2
  var canShoot: Bool = true
  var fireRate: CGFloat = 0.15
  var baseDamage: CGFloat = 1
  
  init(entity: Entity, attackRange: CGFloat = 2, fireRate: CGFloat = 0.15, canShoot: Bool = true) {
    super.init(entity: entity)
    self.attackRange = attackRange
    self.canShoot = canShoot
    self.fireRate = fireRate
  }
  
  func shoot() {
    guard let entity = entity else {return}
    if !canShoot { return }
    entity.run(.sequence([.wait(forDuration: fireRate), .run { [unowned self] in
      self.canShoot = true
    }]))
    checkStatus()
    canShoot = false
  }
}

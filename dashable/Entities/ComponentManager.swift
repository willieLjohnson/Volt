//
//  ComponentManager.swift
//  dashable
//
//  Created by Willie Liwa Johnson on 12/11/21.
//  Copyright © 2021 Willie Johnson. All rights reserved.
//

import Foundation

enum ComponentType {
    case HEALTH
    case BODY
    case CONTROLS
}

protocol Component {
    var type: ComponentType {get set}
    var entityId: UUID { get set }
}


struct ComponentManager {
    var components: [ComponentType: [Component]] = [ComponentType: [Component]] ()
}

//
//  GameViewController.swift
//  dashable
//
//  Created by Willie Johnson on 3/8/18.
//  Copyright © 2018 Willie Johnson. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit


class GameViewController: UIViewController {
  private var debug = true

  override func viewDidLoad() {
    super.viewDidLoad()
    if let view = self.view as! SKView? {
      let gameWorld = GameWorld(game: GameScene(size: view.bounds.size))
      view.presentScene(gameWorld.game)
      // Configure view
      view.ignoresSiblingOrder = true
      if debug {
        view.showsFPS = true
        view.showsDrawCount = true
        view.showsNodeCount = true
      }
    }
  }

  override var shouldAutorotate: Bool {
    return true
  }


  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Release any cached data, images, etc that aren't in use.
  }

  override var prefersStatusBarHidden: Bool {
    return true
  }
}

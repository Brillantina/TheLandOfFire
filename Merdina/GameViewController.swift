//
//  GameViewController.swift
//  Merdina
//
//  Created by Rita Marrano on 03/12/22.
//


//import UIKit
//import SpriteKit
//import GameplayKit
//
//class GameViewController: UIViewController {
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        if let view = self.view as! SKView? {
//            // Load the SKScene from 'GameScene.sks'
//            if let scene = SKScene(fileNamed: "GameScene") {
//                // Set the scale mode to scale to fit the window
//                scene.scaleMode = .aspectFill
//
//                // Present the scene
//                view.presentScene(scene)
//            }
//
//            view.ignoresSiblingOrder = true
//
//            view.preferredFramesPerSecond = 120
//            view.showsFPS = true
//            view.showsNodeCount = true
//            view.showsPhysics = true
//        }
//    }
//
//
//
//
//    var scene = GameScene(size: CGSize(width: 1024, height: 768))
//
//    @IBOutlet weak var refreshGameButton: UIButton!
//
//
////    override func viewDidLoad() {
////        super.viewDidLoad()
////
//////        refreshGameButton.isHidden = true
////
////        let view = self.view as! SKView
////        view.ignoresSiblingOrder = true
////        scene.scaleMode = .aspectFill
////        scene.gameViewControllerBridge = self
////
////        view.presentScene(self.scene)
////    }
//
//    @IBAction func refreshButtonPressed(_ sender: UIButton) {
//
//        refreshGameButton.isHidden = true
//
////        scene.reloadGame()
//    }
//
//
//
//    override var shouldAutorotate: Bool {
//        return true
//    }
//
//    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
//        if UIDevice.current.userInterfaceIdiom == .phone {
//            return .allButUpsideDown
//        } else {
//            return .all
//        }
//    }
//
//    override var prefersStatusBarHidden: Bool {
//        return true
//    }
//}


import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let view = self.view as! SKView
        let myScene = MenuScene(size: view.frame.size)
        view.presentScene(myScene)
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}




//import UIKit
//import SpriteKit
//import GameplayKit
//
//class GameViewController: UIViewController {
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
////        let menuScene = MenuScene()
//
//        if let view = self.view as! SKView? {
//            // Load the SKScene from 'GameScene.sks'
//            if let scene = SKScene(fileNamed: "GameScene") {
//                // Set the scale mode to scale to fit the window
//                scene.scaleMode = .aspectFill
//                scene.isUserInteractionEnabled = true
//
//                // Present the scene
//                view.presentScene(scene)
//            }
//            view.ignoresSiblingOrder = true
//
//            view.showsFPS = false
//            view.showsNodeCount = false
//        }
//    }
//
//    override var shouldAutorotate: Bool {
//        return true
//    }
//
//    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
//        if UIDevice.current.userInterfaceIdiom == .phone {
//            return .landscape
//
//        } else {
//            return .landscape
//        }
//    }
//
//    override var prefersStatusBarHidden: Bool {
//        return true
//    }
//
//}

//
//  PausedState.swift
//  Merdina
//
//  Created by Rita Marrano on 14/12/22.
//

import Foundation
import SpriteKit

class PausedState : SKScene {
    
    
    
    override func didMove(to view: SKView) -> Void {
        
        
        // BACKBUTTON
        let backButton = SKSpriteNode(imageNamed: "buttonResume")
        backButton.setScale(2.5)
        backButton.position = CGPoint(x: self.size.width - 30, y: 330)
        backButton.name = " resumeButton "
        self.addChild(backButton)
        
        


        
        let titleNode : SKLabelNode = SKLabelNode(fontNamed: "STV5730A")
        titleNode.text = "GAME PAUSE"
        titleNode.fontSize = 30
        addChild(titleNode)
        
   
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {
            let location = touch.location(in: self)
            let node = self.nodes(at: location).first
            
            if (node?.name == " resumButton ") {
                let reveal : SKTransition = SKTransition.flipHorizontal(withDuration: 0.5)
                let scene = GameScene(size: self.view!.bounds.size)
                scene.scaleMode = .aspectFill
                self.view?.presentScene(scene, transition:  reveal)
            }
        }
    }
}

//
//  GameScene.swift
//  Merdina
//
//  Created by Rita Marrano on 03/12/22.
//

import CoreMotion
import SpriteKit
import GameplayKit
import AVFAudio

enum CollisionType: UInt32 {
    case player = 1
    case playerWeapon = 2
    case enemy = 4
    case enemyWeapon = 8
    case component = 16
}
var backgroundMusicPlayer = AVAudioPlayer()

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    
    
    
    var backgroundMusicPlayer = AVAudioPlayer()
    var mute: Bool = false
    
    
    
    
    
//    let audio : SKAudioNode
//    let pause = SKAction.pause()
//    audio.run(pause)
    //MARK: - SOUNDS
    
    let buttonSound = SKAction.playSoundFileNamed("bottone", waitForCompletion: false)
    let hitSound = SKAction.playSoundFileNamed("sparo", waitForCompletion: false)
    let deathEnemy = SKAction.playSoundFileNamed("ruota", waitForCompletion: false)
    let gameOverSound = SKAction.playSoundFileNamed("morte", waitForCompletion: false)
    let startClickSound = SKAction.playSoundFileNamed("startclick", waitForCompletion: false)
    let videogiocoSound = SKAction.playSoundFileNamed("Videogame1", waitForCompletion: false)
    
    var pausedGame = false
    
    var cam = SKCameraNode()
    
    var attackButton = SKNode()
    
    
    var upButton = SKNode()
    var downButton = SKNode()
    
    
    let playerSpeed = 7.0
    
    
    //SPRITE ENGINE
    var previousTimeInterval : TimeInterval = 0
    var playerIsFacingRight = true
    
    //PLAYER STATE
    var playerStateMachine : GKStateMachine!
    
    
    var player = SKSpriteNode(imageNamed: "fairy")
    var playerMoveUp = SKAction()
    var playerMoveDown = SKAction()
    
    
    var lastEnemyAdded: TimeInterval = 0
    
    let backgroundVelocity: CGFloat = 3.0
    let enemyVelocity: CGFloat = 5.0
    
    
    let playerCategory = 0x1 << 0
    let enemyCategory = 0x1 << 1
    let componentCategory = 0x1 << 2
    let shootCategory = 0x1 << 3
    
    let wavesComp = Bundle.main.decode([WaveComp].self, from: "WavesComp.geojson")
    let componentTypes = Bundle.main.decode([ComponentType].self, from: "component-types.geojson")
    
    let waves = Bundle.main.decode([Wave].self, from: "waves.geojson")
    let enemyTypes = Bundle.main.decode([EnemyType].self, from: "enemy-types.geojson")
    
    var isPlayerAlive = true
    var levelNumber = 0
    
    var waveNumber = 0
    var waveNumberComp = 0
    
    let sound = SKAction.playSoundFileNamed("Videogame1", waitForCompletion: false)
    
    var playerShields = 5 //VITE
    {
        didSet
        {
            playerShieldsNode.text = "\(playerShields)"
            
        }
    }
    
    let playerShieldsNode : SKLabelNode = SKLabelNode(fontNamed: "STV5730A")
    
    let imageVite = SKSpriteNode(imageNamed: "vite")
    
    
    
    
    
    var score: Int = -0
    {
        didSet
        {
            scoreNode.text = "\(score)"
        }
    }
    
    let scoreNode : SKLabelNode = SKLabelNode(fontNamed: "STV5730A")
    
    
    let positions = Array(stride(from: -320, through: 320, by: 80))
    
    //MARK: DIDMOVE
    
    
    override func didMove(to view: SKView) {
        
        physicsWorld.contactDelegate = self
        
        
        
        
        //MAIN SOUND
        scene!.run(SKAction.sequence([.wait(forDuration: 0.02) ,  .run {
            let backgroundSound = SKAudioNode(fileNamed: "Videogame1")
            self.addChild(backgroundSound)
        } ]))
        
        
        // BACKBUTTON
        let backButton = SKSpriteNode(imageNamed: "buttonBack")
        backButton.zPosition = 2
        backButton.setScale(2.5)
        backButton.position = CGPoint(x: self.size.width - 800, y: 330)
        backButton.name = " backButton "
        self.addChild(backButton)
        
        // Pausebutton
        let pauseButton = SKSpriteNode(imageNamed: "pause")
        pauseButton.zPosition = 2
        pauseButton.setScale(2.5)
        pauseButton.position = CGPoint(x: self.size.width - 50, y: 330)
        pauseButton.name = " pauseButton "
        self.addChild(pauseButton)
        
        
        
        // Sound on button
        let soundButton = SKSpriteNode(imageNamed: "soundOn")
        soundButton.zPosition = 3
        soundButton.setScale(1)
        soundButton.position = CGPoint(x: self.size.width - 120, y: 330)
        soundButton.name = "soundOnButton"
        self.addChild(soundButton)
        
        
        //punti vite
        imageVite.zPosition = 2
        imageVite.setScale(1.5)
        imageVite.position.x = 225
        imageVite.position.y = 340
        addChild(imageVite)
        
        
        
        
        //add score label
        scoreNode.zPosition = 2
        scoreNode.position.x = 150
        scoreNode.position.y = 330
        scoreNode.fontSize = 20
        scoreNode.fontColor = .black
        addChild(scoreNode)
        score = 0
        
        
        
        
        //add lifes label
        playerShieldsNode.zPosition = 2
        playerShieldsNode.position.x = 195
        playerShieldsNode.position.y = 330
        playerShieldsNode.fontSize = 20
        playerShieldsNode.fontColor = .red
        addChild(playerShieldsNode)
        playerShields = 5
        
        
        
        
        enumerateChildNodes(withName: "c3", using: { [self]node, stop in
            
            //        COMPONENT PHYSICS
            let  componentNode = node as! SKSpriteNode
            componentNode.physicsBody = SKPhysicsBody (texture : componentNode.texture!, size: componentNode.size)
            componentNode.physicsBody?.categoryBitMask = UInt32(self.playerCategory)
            componentNode.physicsBody?.collisionBitMask = UInt32(self.componentCategory)
            componentNode.physicsBody?.contactTestBitMask = UInt32(playerCategory)
            componentNode.physicsBody?.affectedByGravity = false
            
        })
        
        if let particles = SKEmitterNode(fileNamed: "Starfield") {
            particles.position = CGPoint(x: 1080, y: 0)
            particles.advanceSimulationTime(60)
            particles.zPosition = -1
            addChild(particles)
        }
        
        
        self.addBackground()
        self.addPlayer()
        self.addComponent()
        self.addAttackButton()
        self.addUpButton()
        self.addDownButton()
        
        // FAIRY FLY
        let FairyFly1 = SKTexture(imageNamed: "fairy1")
        let FairyFly2 = SKTexture(imageNamed: "fairy2")
        let FairyFly3 = SKTexture(imageNamed: "fairy3")
        let FairyFly4 = SKTexture(imageNamed: "fairy4")
        
        player.size = CGSize(width: 230, height: 230)
        player.run(SKAction.repeatForever(
            SKAction.animate(with: [FairyFly1, FairyFly2, FairyFly3, FairyFly4],
                             timePerFrame: 0.3,
                             resize: false,
                             restore: true)),
                   withKey:"iconAnimate")
        
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        
        scene!.run(SKAction.sequence([.wait(forDuration: 0.02) ,  .run {
            let backgroundSound = SKAudioNode(fileNamed: "NectarPiano-Song")
            self.addChild(backgroundSound)
        } ]))
        
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
        
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        
        
        self.moveBackground()
        self.moveComponents()
        
        
        for child in children {
            if child.frame.maxX < 0 {
                if !frame.intersects(child.frame) {
                    child.removeFromParent()
                }
            }
        }
        
        let activeEnemies = children.compactMap { $0 as? EnemyNode }
        
        if activeEnemies.isEmpty {
            createWave()
           // addComponent()

        }
        
        for enemy in activeEnemies {
            guard frame.intersects(enemy.frame) else { continue }
            
            if enemy.lastFireTime + 1 < currentTime {
                enemy.lastFireTime = currentTime
                
                if Int.random(in: 0...6) == 0 {
                    enemy.fire()
                }
            }
        }
        
        
        let activeComponents = children.compactMap { $0 as? ComponentNode }
        
        if activeComponents.isEmpty {
            createWaveComp()
            //addComponent()

        }
        
        for component in activeComponents {
            guard frame.intersects(component.frame) else { continue }
            
//            if component.lastFireTime + 1 < currentTime {
//                component.lastFireTime = currentTime
//
//                if Int.random(in: 0...6) == 0 {
//                    enemy.fire()
//                }
//            }
        }
        
        
    }
    



    func createWave() {
        guard isPlayerAlive else {
            return
        }

        if waveNumber == waves.count{
            levelNumber += 1
            waveNumber = 0
        }

        let currentWave = waves[waveNumber]
        waveNumber += 1

        let maximumEnemyType = min(enemyTypes.count, levelNumber + 1)
        let enemyType = Int.random(in: 0..<maximumEnemyType)

        let enemyOffesetX: CGFloat = 80
        let enemyStartX = 800

        if currentWave.enemies.isEmpty {
            for (index, position) in positions.shuffled().enumerated(){
                let enemy = EnemyNode(type: enemyTypes[enemyType], startPosition: CGPoint(x: enemyStartX, y: position), xOffset: enemyOffesetX * CGFloat(index * 5), moveStraight: true)
                enemy.setScale(1.8)
                enemy.zRotation = CGFloat(1.3)
                addChild(enemy)
            }} else {
                for enemy in currentWave.enemies {
                    let node = EnemyNode(type: enemyTypes[enemyType], startPosition: CGPoint(x: enemyStartX, y: positions[enemy.position]), xOffset: enemyOffesetX * enemy.xOffset, moveStraight: enemy.moveStraight)
                    node.setScale(1.8)
                    node.zRotation = CGFloat(1.3)
                    addChild(node)
                }
            }

        }
    
    
    
    func createWaveComp() {
        
        
        
        
        guard isPlayerAlive else {
            return
        }

        if waveNumberComp == wavesComp.count{
            levelNumber += 1
            waveNumberComp = 0
        }

        let currentWaveComp = wavesComp[waveNumberComp]
        waveNumberComp += 1

        let maximumComponentType = min(componentTypes.count, levelNumber + 1)
        let componentType = Int.random(in: 0..<maximumComponentType)

        let componentOffesetX: CGFloat = 80
        let componentStartX = 800

        if currentWaveComp.components.isEmpty {
            for (index, position) in positions.shuffled().enumerated(){
                let component = ComponentNode(type: componentTypes[componentType], startPosition: CGPoint(x: componentStartX, y: position), xOffset: componentOffesetX * CGFloat(index * 5), moveStraight: true)
                component.setScale(2.5)
                component.physicsBody = SKPhysicsBody(rectangleOf: component.size)
                component.physicsBody?.isDynamic = true
                component.name = "component"
                
//                component.physicsBody?.categoryBitMask = UInt32(componentCategory)
//                component.physicsBody?.contactTestBitMask = UInt32(playerCategory)
//                component.physicsBody?.collisionBitMask = 1
//                component.physicsBody?.usesPreciseCollisionDetection = true
//                component.zRotation = CGFloat(1.3)
                addChild(component)
            }} else {
                for component in currentWaveComp.components {
                    let node = ComponentNode(type: componentTypes[componentType], startPosition: CGPoint(x: componentStartX, y: positions[component.position]), xOffset: componentOffesetX * component.xOffset, moveStraight: component.moveStraight)
                    node.setScale(1.8)
                    node.zRotation = CGFloat(1.3)
                    addChild(node)
                }
            }

        }



    
    func addComponent() {
 
        let path = UIBezierPath()
        path.move(to: .zero)

        let component = SKSpriteNode(imageNamed: "power")
        component.setScale(2.5)
        component.physicsBody = SKPhysicsBody(rectangleOf: component.size)
        component.physicsBody?.isDynamic = true
        component.name = "component"
        
        component.physicsBody?.categoryBitMask = UInt32(componentCategory)
        component.physicsBody?.contactTestBitMask = UInt32(playerCategory)
        component.physicsBody?.collisionBitMask = 1
        component.physicsBody?.usesPreciseCollisionDetection = true
        
        
        
        let random: CGFloat = CGFloat(arc4random_uniform(300))
        component.position = CGPoint(x: self.frame.size.width + random, y: random)
        
        path.addCurve(to: CGPoint(x: -3500, y: 0), controlPoint1: CGPoint(x: 0, y: -position.y * 4), controlPoint2: CGPoint(x: -1000, y: -position.y))
        
        self.addChild(component)
    }
    
    
    func moveComponents() {
        self.enumerateChildNodes(withName: "component", using: { (node, stop) -> Void in
            if let component = node as? SKSpriteNode {
                component.position = CGPoint(x: component.position.x - self.enemyVelocity, y: component.position.y)
                
                
                if component.position.x < 0  {
                    component.removeFromParent()
                }
            }
    })
}
    

    
    
    
    func addAttackButton() {
        attackButton = SKSpriteNode(imageNamed: "pad")
        attackButton.setScale(2.5)
        attackButton.zPosition = 3
        attackButton.physicsBody?.isDynamic = false
        attackButton.physicsBody?.affectedByGravity = false
          
        attackButton.name = "attackButton"
        attackButton.position = CGPoint(x: 740, y: 70)
        self.addChild(attackButton)
}

    
    func addUpButton() {
        upButton = SKSpriteNode(imageNamed: "upButton")
        upButton.setScale(1.15)
        attackButton.zPosition = 3
        upButton.physicsBody?.isDynamic = false
        attackButton.physicsBody?.affectedByGravity = false
          
        upButton.name = "upButton"
        upButton.position = CGPoint(x: 70, y: 250)
        self.addChild(upButton)
}
    
    
    func addDownButton() {
        downButton = SKSpriteNode(imageNamed: "downButton")
        downButton.setScale(1.15)
        downButton.zPosition = 3
        downButton.physicsBody?.isDynamic = false
        attackButton.physicsBody?.affectedByGravity = false
          
        downButton.name = "downButton"
        downButton.position = CGPoint(x: 70, y: 120)
        self.addChild(downButton)
}
    
    
    
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }

        let sortedNodes = [nodeA, nodeB].sorted { $0.name ?? "" < $1.name ?? "" }
        let firstNode = sortedNodes[0]
        let secondNode = sortedNodes[1]

//        if secondNode.name == "player" {
//            guard isPlayerAlive else { return }
//
//            if let explosion = SKEmitterNode(fileNamed: "Explosion") {
//                explosion.position = firstNode.position
//                addChild(explosion)
//
//            }
//            run (deathEnemy)
//            playerShields -= 1
//
//            if playerShields == 0 {
//                gameOver()
////                updateHighScore(with: score)
//            }
//
//            firstNode.removeFromParent()
//
//        } else if let enemy = firstNode as? EnemyNode {
//
//            enemy.shields -= 1
//
//            if enemy.shields == 0 {
//                if let explosion = SKEmitterNode(fileNamed: "Explosion") {
//                    explosion.position = enemy.position
//                    addChild(explosion)
//                }
//                enemy.removeFromParent()
//            }
//
//            if let explosion = SKEmitterNode(fileNamed: "Explosion") {
//                explosion.position = enemy.position
//                addChild(explosion)
//            }
//
//            secondNode.removeFromParent()
//        } else {
//            if let explosion = SKEmitterNode(fileNamed: "Explosion") {//qua forse
//                explosion.position = secondNode.position
//                run (deathEnemy)
//                addChild(explosion)
//                score += 6
//            }
//            firstNode.removeFromParent()
//            secondNode.removeFromParent()
//        }
        
        if let component = firstNode as? ComponentNode {
            playerShields += 1
                score += 10
                component.removeFromParent()
            
            
        } else if (secondNode.name == "player"){
            
  
            guard isPlayerAlive else { return }

            if let explosion = SKEmitterNode(fileNamed: "Explosion") {
                explosion.position = firstNode.position
                addChild(explosion)
               
            }
            run (deathEnemy)
            playerShields -= 1

            if playerShields == 0 {
                gameOver()
//                updateHighScore(with: score)
            }

            firstNode.removeFromParent()

            
        } else if let enemy = firstNode as? EnemyNode {

            enemy.shields -= 1

            if enemy.shields == 0 {
                if let explosion = SKEmitterNode(fileNamed: "Explosion") {
                    explosion.position = enemy.position
                    addChild(explosion)
                }
                enemy.removeFromParent()
            }

            if let explosion = SKEmitterNode(fileNamed: "Explosion") {
                explosion.position = enemy.position
                addChild(explosion)
            }
            
            secondNode.removeFromParent()
            
        } else {
            if let explosion = SKEmitterNode(fileNamed: "Explosion") {//qua forse
                explosion.position = secondNode.position
                run (deathEnemy)
                addChild(explosion)
                score += 6
            }
            firstNode.removeFromParent()
            secondNode.removeFromParent()
        }
        
        
//        guard let nodeA = contact.bodyA.node else { return }
//        guard let nodeB = contact.bodyB.node else { return }
//        if (nodeA.name == "component" && nodeB == player) || (nodeA == player && nodeB.name == "component") {
//            
//            if contact.bodyB.node?.name == "component"{
//                score += 10
//                playerShields += 1
//                contact.bodyB.node?.removeFromParent()
//            }
//            
//        }
        
        
        
        
}

    
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isPlayerAlive else { return }
        
        
        for touch: AnyObject in touches {
            let location = touch.location(in: self)
            
            let node = self.atPoint(location)
            

//             if (node.name == "soundOnButton"){
//                run(buttonSound)
//                if !isPaused {return}
//                let impactMed = UIImpactFeedbackGenerator(style: .medium)
//                impactMed.impactOccurred(intensity: 0.8)
//                isPaused = true
//                node.removeFromParent()
//
//                // mutebutton
//                let soundOffButton = SKSpriteNode(imageNamed: "soundOff")
//                soundOffButton.zPosition = 3
//                soundOffButton.setScale(1)
//                soundOffButton.position = CGPoint(x: self.size.width - 120, y: 330)
//                soundOffButton.name = "soundOffButton"
//                self.addChild(soundOffButton)
//
//
//            } else if (node.name == "soundOffButton"){
//                run(buttonSound)
//                if !isPaused {return}
//                let impactMed = UIImpactFeedbackGenerator(style: .medium)
//                impactMed.impactOccurred(intensity: 0.8)
//                isPaused = false
//                node.removeFromParent()
//
//
//                // Sound on button
//                let soundButton = SKSpriteNode(imageNamed: "soundOn")
//                soundButton.zPosition = 2
//                soundButton.setScale(1)
//                soundButton.position = CGPoint(x: self.size.width - 120, y: 330)
//                soundButton.name = "soundOnButton"
//                self.addChild(soundButton)
//
//            }
            
            
            
            if(node.name == " pauseButton "){
                if isPaused {return}
                run(buttonSound)
                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                impactMed.impactOccurred()
                isPaused = true
                print("paused")
                node.removeFromParent()
                
                
                
                
                // Resumebutton
                let resumeButton = SKSpriteNode(imageNamed: "resume")
                resumeButton.zPosition = 3
                resumeButton.setScale(2.5)
                resumeButton.position = CGPoint(x: self.size.width - 50, y: 330)
                resumeButton.name = " resumeButton "
                self.addChild(resumeButton)
                
                
            }else if (node.name == " resumeButton "){
                run(buttonSound)
                if !isPaused {return}
                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                impactMed.impactOccurred(intensity: 0.8)
                isPaused = false
                node.removeFromParent()
                
                // Pausebutton
                let pauseButton = SKSpriteNode(imageNamed: "pause")
                pauseButton.zPosition = 3
                pauseButton.setScale(2.9)
                pauseButton.position = CGPoint(x: self.size.width - 55, y: 330)
                pauseButton.name = " pauseButton "
                self.addChild(pauseButton)
                
                
            }

            else if (node.name == "attackButton") {
                
                let impactMed = UIImpactFeedbackGenerator(style: .heavy)
                    impactMed.impactOccurred(intensity: 0.8) //MARK CONTROLLARE SE FUNZIONA
                
                    shoot()
                }
            else if (node.name == " backButton ") {
                    
                    let impactMed = UIImpactFeedbackGenerator(style: .medium)
                        impactMed.impactOccurred() //MARK CONTROLLARE SE FUNZIONA
                    
                let reveal : SKTransition = SKTransition.flipHorizontal(withDuration: 0.5)
                let scene = MenuScene(size: self.view!.bounds.size)
                scene.scaleMode = .aspectFill
                self.view?.presentScene(scene, transition:  reveal)
            } else if (node.name == "upButton") {
                
                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                impactMed.impactOccurred() //MARK CONTROLLARE SE FUNZIONA
                
                    if player.position.y < 380 {
                        player.run(playerMoveUp)
                    
                }
            } else if (node.name == "downButton") {
                
                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                impactMed.impactOccurred() //MARK CONTROLLARE SE FUNZIONA
                
                
                if player.position.y > 60 {
                    player.run(playerMoveDown)
                }
   
            } else if (node.name == "soundOnButton"){
                run(buttonSound)
                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                impactMed.impactOccurred(intensity: 0.8)
                mute = true
                node.removeFromParent()
                backgroundMusicPlayer.pause()
                backgroundMusicPlayer.volume = 0
                
                // mutebutton
                let soundOffButton = SKSpriteNode(imageNamed: "soundOff")
                soundOffButton.zPosition = 3
                soundOffButton.setScale(1)
                soundOffButton.position = CGPoint(x: self.size.width - 120, y: 330)
                soundOffButton.name = "soundOffButton"
                self.addChild(soundOffButton)
                
                
            } else if (node.name == "soundOffButton"){
                run(buttonSound)
                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                impactMed.impactOccurred(intensity: 0.8)
                node.removeFromParent()
                mute = false
                backgroundMusicPlayer.play()
                backgroundMusicPlayer.volume = 1
                // Sound on button
                let soundButton = SKSpriteNode(imageNamed: "soundOn")
                soundButton.zPosition = 3
                soundButton.setScale(1)
                soundButton.position = CGPoint(x: self.size.width - 120, y: 330)
                soundButton.name = "soundOnButton"
                self.addChild(soundButton)
                
            }
                
        }
    }
    
    func shoot() {
        
        
        
        let projectile = SKSpriteNode(imageNamed: "fairyShoot")
        projectile.setScale(0.30)
        projectile.zPosition = 1
        projectile.position = CGPoint(x: (player.position.x + 50) , y: (player.position.y)-15)

        projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
        projectile.physicsBody?.isDynamic = true
        projectile.physicsBody?.categoryBitMask = UInt32(playerCategory)
        projectile.physicsBody?.contactTestBitMask = UInt32(enemyCategory)
        projectile.physicsBody?.collisionBitMask = 1
        projectile.physicsBody?.usesPreciseCollisionDetection = true

        
        let frame1 = SKTexture(imageNamed: "shoot1")
        let frame2 = SKTexture(imageNamed: "shoot2")
        let frame3 = SKTexture(imageNamed: "shoot3")
        let frame4 = SKTexture(imageNamed: "shoot4")
        let frame5 = SKTexture(imageNamed: "shoot5")
        
        projectile.run(SKAction.repeatForever(
            SKAction.animate(with: [frame1,frame2,frame3,frame4, frame5],
                             timePerFrame: 0.2,
                             resize: false,
                             restore: true)),
                 withKey:"iconAnimate")
        
        
        let fairy1 = SKTexture(imageNamed: "shooting1")
        let fairy2 = SKTexture(imageNamed: "shooting2")
        let fairy3 = SKTexture(imageNamed: "shooting3")
        let fairy4 = SKTexture(imageNamed: "shooting4")
        let frames = [fairy1, fairy2, fairy3, fairy4]
        
        player.size = CGSize(width: 270, height: 270)
        player.run(SKAction.animate(with: frames, timePerFrame: 0.1))
        
        
        self.addChild(projectile)
        
        let action = SKAction.moveTo(x: self.frame.width + projectile.size.width, duration: 0.7)

        run (hitSound)


        projectile.run(action, completion: {
            projectile.removeAllActions()
            projectile.removeFromParent()
        })
    }

    func gameOver() {
        isPlayerAlive = false

        if let explosion = SKEmitterNode(fileNamed: "Explosion") {
            explosion.position = player.position
            run (gameOverSound)
            addChild(explosion)
        }

        
        let gameOverScene = ScoreSceneGameOver(size: self.size)
        gameOverScene.score = score
        updateHighScore(with: score)
        self.view?.presentScene(gameOverScene, transition: .doorway(withDuration: 0.5))
    }


    
    func addPlayer () {
        player = SKSpriteNode(imageNamed: "player")
        player.setScale(0.05)
        
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size )
        player.physicsBody?.isDynamic = false
        player.physicsBody?.affectedByGravity = false
        
        // collision
        player.physicsBody?.categoryBitMask = UInt32(playerCategory)
        player.physicsBody?.contactTestBitMask = UInt32(enemyCategory)
        player.physicsBody?.collisionBitMask = 1
        
        
        player.name = "player"
        player.position = CGPoint(x: 135, y: 160)
        
        
        playerMoveUp = SKAction.moveBy(x: 0, y: 30, duration: 0.1)
        playerMoveDown = SKAction.moveBy(x: 0, y: -30, duration: 0.1)
        self.addChild(player)
        
}
    

    func addBackground(){

        
        for index in 0..<2 {
            let bg = SKSpriteNode(imageNamed: "background")
            bg.size = CGSize(width: size.width, height: size.height)
            bg.position = CGPoint(x: index * Int(bg.size.width), y: 0)
            bg.anchorPoint = CGPoint(x: 0, y: 0)
            bg.name = "background"
            
            self.addChild(bg)
        }
}
    
    
    func moveBackground() {
        self.enumerateChildNodes(withName: "background", using: {(node, stop) -> Void in
            if let bg = node as? SKSpriteNode {
                bg.position = CGPoint(x: bg.position.x - self.backgroundVelocity, y: bg.position.y)
                
                if bg.position.x <= -bg.size.width {
                    bg.position = CGPoint(x: bg.position.x + bg.size.width * 2, y: bg.position.y)
                }
            }
        })
    }
    
}





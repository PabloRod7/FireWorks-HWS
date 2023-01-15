//
//  GameScene.swift
//  Project 20
//
//  Created by Pablo Rodrigues on 30/12/2022.
//

import SpriteKit


class GameScene: SKScene {
    
    var gameTimer: Timer?
    var fireWorks = [SKNode]()
//    Challenge 1
    var scoreLabel : SKLabelNode!
    var gameOverLabel : SKLabelNode!
    
    let leftEdge = -22
    let bottomEdge = -22
    let rightEdge = 1024 + 22
    
    
    
    var numLaunches = 0
    var score = 0 {
        didSet {
            scoreLabel?.text = "Score is  \(score)"
        }
    }
    
    
    override func didMove(to view: SKView) {
        
        let backGround = SKSpriteNode(imageNamed: "background")
        backGround.position = CGPoint(x: 512, y: 384)
        backGround.blendMode = .replace
        backGround.zPosition = -1
        addChild(backGround)
//        challenge 1
        
        
        
        
        
        
        
        
        scoreLabel = SKLabelNode(fontNamed: "GillSans-UltraBold")
        scoreLabel?.position = CGPoint(x: 50, y: 50)
        scoreLabel?.horizontalAlignmentMode = .left
        scoreLabel?.fontColor = UIColor(red: 1, green: 0.2, blue: 0, alpha: 1)
        addChild(scoreLabel)
        score = 0
        
        gameTimer = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(launchFireworks), userInfo: nil, repeats: true)
        
        
        
    }
        func creatFireworks(xMovement: CGFloat, x : Int, y: Int) {
            let node = SKNode()
            node.position = CGPoint(x: x, y: y)
            
            let firework = SKSpriteNode(imageNamed: "rocket3")
            firework.size = CGSize(width: 25, height: 120)
            firework.colorBlendFactor = 1
            firework.name = "firework"
            node.addChild(firework)
            numLaunches += 1
           
            switch Int.random(in: 0...2) {
            case 0:
                firework.color = .cyan
            case 1:
                firework.color = .green
            default:
                firework.color = .red
            }
            
            let path = UIBezierPath()
            path.move(to: .zero)
            path.addLine(to: CGPoint(x: xMovement, y: 1000))
            
            let move = SKAction.follow(path.cgPath, asOffset: true, orientToPath: true, speed: 200)
            node.run(move)
            
             if let emitter = SKEmitterNode(fileNamed: "fuse"){
                emitter.position = CGPoint(x: 0, y: -50)
                node.addChild(emitter)
            }
            
            fireWorks.append(node)
            addChild(node)
            
            if numLaunches >= 50 {
                gameOver()
                
            }
           
            
        }
        
        @objc func launchFireworks(){
            
            let movementAmount : CGFloat = 1800
            
            switch Int.random(in: 0...3){
            case 0:
                //            fire five straight up
                creatFireworks(xMovement: 0, x: 512, y: bottomEdge)
                creatFireworks(xMovement: 0, x: 512 - 200, y: bottomEdge)
                creatFireworks(xMovement: 0, x: 512 - 100, y: bottomEdge)
                creatFireworks(xMovement: 0, x: 512 + 100, y: bottomEdge)
                creatFireworks(xMovement: 0, x: 512 + 200, y: bottomEdge)
                
            case 1:
                //            fire five in fan
                creatFireworks(xMovement: 0, x: 512, y: bottomEdge)
                creatFireworks(xMovement: -200, x: 512 - 200, y: bottomEdge)
                creatFireworks(xMovement: -100, x: 512 - 100, y: bottomEdge)
                creatFireworks(xMovement: +100, x: 512 + 100, y: bottomEdge)
                creatFireworks(xMovement: +200, x: 512 + 200, y: bottomEdge)
                
            case 2:
                creatFireworks(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 400)
                creatFireworks(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 300)
                creatFireworks(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 200)
                creatFireworks(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 100)
                creatFireworks(xMovement: movementAmount, x: leftEdge, y: bottomEdge)
                
            case 3:
                creatFireworks(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 400)
                creatFireworks(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 300)
                creatFireworks(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 200)
                creatFireworks(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 100)
                creatFireworks(xMovement: -movementAmount, x: rightEdge, y: bottomEdge)
            default:
                break
            }
            
            
            
        }
    
    func checkTouches(_ touches: Set<UITouch>) {
        guard let touch = touches.first else {return}
        
        let location = touch.location(in: self)
        let nodesAtpoint = nodes(at: location)
        
        for case let node as SKSpriteNode in nodesAtpoint {
            guard node.name == "firework" else {return}
            
            for parent in fireWorks {
                guard let firework = parent.children.first as? SKSpriteNode else {return}
                if firework.name == "selected" && firework.color
                    != node.color {
                    firework.name = "firework"
                    firework.colorBlendFactor = 1
                    
                }
            }
            
            node.name = "selected"
            node.colorBlendFactor = 0
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        checkTouches(touches)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        checkTouches(touches)
    }
  
    override func update(_ currentTime: TimeInterval) {
        for (index, firework) in fireWorks.enumerated().reversed() {
            if firework.position.y > 900 {
                fireWorks.remove(at: index)
                firework.removeFromParent()
            }
        }
    }
    func explode(firework: SKNode) {
        if let emitter = SKEmitterNode(fileNamed: "explode") {
            emitter.position = firework.position
            addChild(emitter)
            
            
        let waitAction = SKAction.wait(forDuration: 2)
            let removeAction = SKAction.run { emitter.removeFromParent() }
                let sequence = SKAction.sequence([waitAction, removeAction])
                        emitter.run(sequence)
        }
        firework.removeFromParent()
            
    }
    func explodeFirework(){
        var numExplode = 0
        
        for (index, fireworkContainer) in fireWorks.enumerated().reversed() {
            guard let firework = fireworkContainer.children.first as? SKSpriteNode else {continue}
            
            if firework.name == "selected" {
                explode(firework: fireworkContainer)
                fireWorks.remove(at: index)
                numExplode += 1
            }
        }
        
        switch numExplode {
        case 0:
            break
        case 1:
            score += 200
        case 2:
            score += 500
        case 3:
            score += 1500
        case 4:
            score += 2500
        default:
            score += 4000
        }
    }
    
    func gameOver(){
        gameTimer?.invalidate()
        
        gameOverLabel = SKLabelNode(fontNamed: "GillSans-UltraBold")
        gameOverLabel.position = CGPoint(x: 512, y: 300)
        gameOverLabel?.fontSize = 100
        gameOverLabel.horizontalAlignmentMode = .center
        gameOverLabel?.text = "GAME OVER"
        addChild(gameOverLabel)
        
        
    }
    
    }

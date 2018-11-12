//
//  Rocket.swift
//  SmartRockets
//
//  Created by Julian Abhari on 1/29/17.
//  Copyright © 2017 Julian Abhari. All rights reserved.
//

import Foundation
import SpriteKit

class Rocket: SKSpriteNode {
    var genes: [CGPoint] = []
    var count = 0
    var rocketFitness: CGFloat = 0
    
    var location: CGPoint
    var velocity: CGPoint
    var acceleration: CGPoint
    
    init (imageName: String, x: CGFloat, y: CGFloat) {
        //let imageTexture = SKTexture(imageNamed: imageName)
        location = CGPoint(x: x, y: y)
        velocity = CGPoint(x: 0, y: 0)
        acceleration = CGPoint(x: 0, y: 0)
        
        super.init(texture: nil, color: UIColor.white.withAlphaComponent(0.67), size: CGSize(width: 10, height: 50))
        position = location
        
        for _ in 0..<GameScene.GENE_SIZE - 3 {
            genes.append(CGPoint(x: randomNumber(), y: randomNumber()))
        }
        
        for _ in GameScene.GENE_SIZE - 3..<GameScene.GENE_SIZE {
            genes.append(CGPoint(x: drand48(), y: drand48()))
        }
        self.color = UIColor.init(red: genes[genes.count - 3].x + 0.2, green: genes[genes.count - 2].x + 0.2, blue: genes[genes.count - 1].x + 0.2, alpha: 0.67)
    }
    
    func update() {
        if !(hasCompleted()) {
            acceleration.x = genes[count].x
            acceleration.y = genes[count].y
            
            velocity.x += acceleration.x
            velocity.y += acceleration.y
            
            location.x += velocity.x
            location.y += velocity.y
            
            position = location
            
            if LevelViewController.levelName!.caseInsensitiveCompare("Fidget Spinner") == ComparisonResult.orderedSame || LevelViewController.levelName!.caseInsensitiveCompare("Spinner") == ComparisonResult.orderedSame {
                zRotation = velocity.x + velocity.y
            }
            if LevelViewController.levelName!.caseInsensitiveCompare("Fluid") == ComparisonResult.orderedSame {
                zRotation = CGFloat(atan2f(Float(location.x), Float(location.y)))
            }
            
            acceleration.x *= 0
            acceleration.y *= 0
            
            count += 1
        }
    }
    
    func calculateFitness() -> CGFloat {
        // This line of code isn't that complicated, it's mostly casting CGFloats to Floats, and Floats to CGFloats
        let distance: CGFloat = CGFloat(Math().dist(startingX: Float(location.x), startingY: Float(location.y), endingX: Float(GameScene.target!.position.x), endingY: Float(GameScene.target!.position.y)))
        // This line of code isn't that complicated, it's mostly casting CGFloats to Floats, and Floats to CGFloats
        var rocketFitness: CGFloat = CGFloat(Math().map(value: Float(distance), valMin: 0, valMax: Float(GameScene.width), mapMin: Float(GameScene.width), mapMax: 0))
        
        if (rocketFitness < 0) {
            rocketFitness = 1
        }
        
        if PopulationViewController.damageIfCrash {
            if hasCrashed() {
                rocketFitness /= 10
            }
        }
        
        if PopulationViewController.damageIfHitWall {
            if hasHitWall() {
                rocketFitness /= 10
            }
        }
        
        return rocketFitness
    }
    
    func getFitness() -> CGFloat {
        self.rocketFitness = calculateFitness()
        return rocketFitness
    }
    
    // This tells whether the rocket has completed by seeing if it is near the
    // maximum fitness minus 20 or if the count is >= the MAX_COUNT.
    func hasCompleted() -> Bool {
        if (calculateFitness() >= GameScene.width - 20) {
            return true
        }
        if PopulationViewController.wallBoundary {
            if hasHitWall() {
                return true
            }
        }
        if hasCrashed() {
            return true
        }
        if (count >= GameScene.GENE_SIZE) {
            return true
        }
        return false
    }
    
    func hasCrashed() -> Bool {
        for i in 0..<GameViewController.numOfObstacles {
            if  location.x >= GameScene.obstacles[i].position.x - 250 &&
                location.x <= GameScene.obstacles[i].position.x + 250 &&
                location.y >= GameScene.obstacles[i].position.y - 25 &&
                location.y <= GameScene.obstacles[i].position.y + 25 {
                return true
            }
        }
        
        return false
    }
    
    func hasHitWall() -> Bool {
        if  location.x >= (GameScene.width / 2) ||
            location.x <= (GameScene.width / -2) ||
            location.y >= (GameScene.height / 2) ||
            location.y <= (GameScene.height / -2) {
            return true
        }
        return false
    }
    
    func randomNumber() -> CGFloat {
        var ranNum: Double = drand48()
        let ranFiftyNum = arc4random_uniform(10)
        if ranFiftyNum >= 5 {
            ranNum *= -1
        }
        return CGFloat(ranNum)
    }
    
    func setGenes(genesArray: [CGPoint]) {
        genes = genesArray
        
        self.color = UIColor.init(red: genesArray[genesArray.count - 3].x + 0.2, green: genesArray[genesArray.count - 2].x + 0.2, blue: genesArray[genesArray.count - 1].x + 0.2, alpha: 0.67)
    }
    
    func getGenes() -> [CGPoint] {
        return genes
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

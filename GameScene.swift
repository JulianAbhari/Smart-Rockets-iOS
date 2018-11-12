//
//  GameScene.swift
//  SmartRockets
//
//  Created by Julian Abhari on 1/7/17.
//  Copyright © 2017 Julian Abhari. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    static let GENE_SIZE = 403
    let TOURNAMENT_SELECTION_SIZE = 4
    var MUTATION_RATE: Float = PopulationViewController.mutationRate
    var populationSize = PopulationViewController.populationSize
    
    var generation = 1
    var tempMaxFitness: Int = 0
    var maxFitness: CGFloat = 0
    
    
    static var width: CGFloat = 0
    static var height: CGFloat = 0
    
    var rockets : [Rocket?] = []
    var generationLabel: SKLabelNode?
    var fitnessLabel: SKLabelNode?
    
    static var obstacles: [SKShapeNode] = []
    static var target: SKShapeNode? = nil
    
    var count = 0
    static var isAddingObstacle: Bool = false
    static var isDeletingObstacle: Bool = false
    static var hasFinishedLevelCreation: Bool = false
    var rocketsHaveNotBeenInitialized: Bool = true
    
    // This method is executed frist and only once
    override func didMove(to view: SKView) {
        UIApplication.shared.isIdleTimerDisabled = true
        
        backgroundColor = UIColor.black
        // Initializing Variables
        GameScene.width = frame.size.width
        GameScene.height = frame.size.height
       
        // Initializing Generation Label
        generationLabel = SKLabelNode(text: "Generation: \(generation)")
        generationLabel?.fontName = "Trebuchet MS"
        generationLabel?.fontSize = 50
        generationLabel?.position = CGPoint(x: frame.size.width/(-5), y: frame.size.height/(-2.3))
        
        // Initializing Fitness Label
        fitnessLabel = SKLabelNode(text: "Highest Fitness: \(Int(maxFitness))")
        fitnessLabel?.fontName = "Trebuchet MS"
        fitnessLabel?.fontSize = 45
        fitnessLabel?.position = CGPoint(x: frame.size.width/(-5), y: frame.size.height/(-2.1))
        
        // Initializing Target
        GameScene.target = SKShapeNode(circleOfRadius: 25)
        GameScene.target?.position = CGPoint(x: 0, y: frame.size.height/(3))
        GameScene.target?.fillColor = UIColor.white
        addChild(GameScene.target!)
        
        // Initializing Obstacles
        GameScene.obstacles = []
        for i in 0..<GameViewController.numOfObstacles {
            GameScene.obstacles.append(SKShapeNode(rect: CGRect(x: -250, y: -25, width: 500, height: 50)))
            GameScene.obstacles[i].fillColor = UIColor.white
            addChild(GameScene.obstacles[i])
        }
    }
    
    // This method loops through the rockets array and calls their update methods
    func updateRockets() {
        for i in 0..<populationSize {
            rockets[i]?.update()
        }
    }
    
    func initializeRocketsArray(populationSize: Int) {
        for i in 0..<populationSize {
            rockets.append(Rocket(imageName: "rocket", x: 0, y: frame.size.height/(-3)))
            addChild(rockets[i]!)
        }
    }
    
    // Update Method
    override func update(_ currentTime: TimeInterval) {
        if GameScene.hasFinishedLevelCreation {
            if rocketsHaveNotBeenInitialized {
                rocketsHaveNotBeenInitialized = false
                addChild(generationLabel!)
                addChild(fitnessLabel!)
                initializeRocketsArray(populationSize: populationSize)
            }
            if !(count >= GameScene.GENE_SIZE - 3) {
                updateRockets()
                count += 1
            }
            if count >= GameScene.GENE_SIZE - 3 {
                generation += 1
                
                generationLabel?.text = "Generation: \(generation)"
                calculateHighestFitness(population: rockets as! [Rocket])
                fitnessLabel?.text = "Highest Fitness: \(Int(maxFitness))"
                
                //checkLocalMinimum(maxFitness: Int(maxFitness))
                  
                for i in 0..<populationSize {
                    rockets[i]?.removeFromParent()
                }
                rockets = evolvePopulation(population: rockets as! [Rocket])
                for i in 0..<populationSize {
                    addChild(rockets[i]!)
                }
                count = 0
            }
        }
    }
    
    func checkLocalMinimum(maxFitness: Int) {
        if tempMaxFitness == Int(maxFitness) {
            MUTATION_RATE += 0.02
            tempMaxFitness = Int(maxFitness)
            print("Local Minimum Found")
            
        } else {
            tempMaxFitness = Int(maxFitness)
            print(tempMaxFitness)
            MUTATION_RATE = PopulationViewController.mutationRate
        }
    }
    
    func intersectedBar(location: CGPoint, obstacle: SKShapeNode) -> Bool {
        if  location.x >= obstacle.position.x - 250 &&
            location.x <= obstacle.position.x + 250 &&
            location.y >= obstacle.position.y - 50 &&
            location.y <= obstacle.position.y + 50 {
            
            return true
        }
        return false
    }
    
    func intersectedTarget(location: CGPoint) -> Bool {
        if  location.x >= GameScene.target!.position.x - 50 &&
            location.x <= GameScene.target!.position.x + 50 &&
            location.y >= GameScene.target!.position.y - 50 &&
            location.y <= GameScene.target!.position.y + 50 {
            return true
        }
        return false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            
            if GameScene.isAddingObstacle {
                GameViewController.numOfObstacles += 1
                let location = t.location(in: self)
                GameScene.obstacles.append(SKShapeNode(rect: CGRect(x: -250, y: -25, width: 500, height: 50)))
                GameScene.obstacles.last!.fillColor = UIColor.white
                GameScene.obstacles.last!.position = location
                addChild(GameScene.obstacles.last!)
                GameScene.isAddingObstacle = false
            }
            
            for i in 0..<GameViewController.numOfObstacles {
                if GameScene.isDeletingObstacle && intersectedBar(location: t.location(in: self), obstacle: GameScene.obstacles[i]) {
                    GameViewController.numOfObstacles -= 1
                    GameScene.obstacles[i].removeFromParent()
                    GameScene.obstacles.remove(at: i)
                    GameScene.isDeletingObstacle = false
                }
            }

            if intersectedTarget(location: t.location(in: self)) {
                GameScene.target?.position = t.location(in: self)
            }
            
            for i in 0..<GameViewController.numOfObstacles {
                if intersectedBar(location: t.location(in: self), obstacle: GameScene.obstacles[i]) {
                    GameScene.obstacles[i].position = t.location(in:self)
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            
            if intersectedTarget(location: t.location(in: self)) {
                GameScene.target?.position = t.location(in: self)
            }
            
            for i in 0..<GameViewController.numOfObstacles {
                if intersectedBar(location: t.location(in: self), obstacle: GameScene.obstacles[i]) {
                    GameScene.obstacles[i].position = t.location(in:self)
                }
            }
        }
    }

    
    /*=========================
     *----Genetic Algorithm----
     *=========================
     */
    
    // This function takes in a population and returns a mutated crossovered
    // version of that population.
    func evolvePopulation(population: [Rocket]) -> [Rocket] {
        return mutatePopulation(population: crossoverPopulation(population: population));
    }
    
    // This function returns a rocket but takes in two rockets.
    func crossoverRocket(rocket1: Rocket, rocket2: Rocket) -> Rocket {
        // This creates new rocket whose genes will be overriden by the rocket1
        // and/or rocket2 genes.
        let crossoverRocket = Rocket(imageName: "rocket", x: 0, y: frame.size.height/(-3))
        // This is creating an empty array to be set as the crossoverRocket's genes
        var crossoverGenes: [CGPoint] = []
        // This is looping through the length of rocket1 (and rocket2)'s genes.
        for i in 0..<rocket1.getGenes().count {
            // If a random number between 0.0 - 1.0 is < 0.5, then the new
            // rocket will have rocket1's genes. Otherwise it will have
            // rocket2's genes.
            if (arc4random_uniform(10) < 5) {
                crossoverGenes.append(rocket1.getGenes()[i])
            } else {
				crossoverGenes.append(rocket2.getGenes()[i])
            }
        }
        crossoverRocket.setGenes(genesArray: crossoverGenes)
        return crossoverRocket;
    }
    
    // This function takes in a population and returns a crossovered version of
    // that population.
    func crossoverPopulation(population: [Rocket]) -> [Rocket] {
        // This is creating the crossoverPopulation, whose population size is
        // the same as the given population.
        var crossoverPopulation: [Rocket] = []
        // This maxFitness needs to be set to 0 everytime this function is
        // called, because if it wasn't then it would be the same as the last
        // generation's maxFitness, unless the new generation's fitness is
        // higher. Basically if the given generation has a lower maxFitness
        // than the previous, then it would still think that the maxFitness is
        // the maxFitness of the previous generation. The maxFitness variable is
        // a global variable because it will be called in other functions.
        maxFitness = 0;
        // This is looping through the given generation's rockets and seeing if
        // any of their fitness scores are higher than the maxFitness (which is
        // 0), if it is, then the maxFitness is set to that fitness.
        for i in 0..<population.count {
            if population[i].getFitness() > maxFitness {
                // This is declaring the maxFitness to be that rocket's fitness
                // score.
                maxFitness = population[i].getFitness();
            }
        }
        // This is looping through the given population's rockets and crossing
        // over two rockets from the matingPool.
        for _ in 0..<population.count {
            // This is setting rocket1 to the best rocket out of the
            // matingPool's population.
            let rocket1 = matingPoolByFitness(population: population)[0]
            // This is setting rocket2 to the best rocket out of the
            // matingPool's population.
            let rocket2 = matingPoolByFitness(population: population)[0]
            // This setting the new crossoverPopulation's rocket at index i to
            // be a crossovered rocket of rocket1 and rocket2.
            crossoverPopulation.append(crossoverRocket(rocket1: rocket1, rocket2: rocket2))
        }
        return crossoverPopulation;
    }
    
    // This mutateRocket function takes in a rocket, and returns the same rocket
    // however, within the mutation rate, there could be a chance that the new
    // rockets genes might be mutated.
    func mutateRocket(rocket: Rocket) -> Rocket {
        // This is creating a new rocket which will get the given rockets genes
        // with some mutation.
        let mutatedRocket = Rocket(imageName: "rocket", x: 0, y: frame.size.height/(-3))
        // This is creating an empty array to set as the mutatedRocket's genes
        var mutatedGenes: [CGPoint] = []
        // This is looping through the given rockets genes, and if a random
        // number is <= the MUTATION_RATE then that gene[i] (which is a vector)
        // will have it's X and Y overriden by a randomNumber (between -1 and 1).
        for i in 0..<rocket.getGenes().count {
            if Float(drand48()) <= MUTATION_RATE {
				// This is giving a mutated version of the given rockets genes
				// to the mutatedRocket. Since the genes are JVectors it
				// override the JVectors X and Y with a randomNumber. The
				// randomNumber function is found within the rocket class, so it
				// just calls the new rocket to input it's randomNumber output.
                mutatedGenes.append(CGPoint(x: mutatedRocket.randomNumber(), y: mutatedRocket.randomNumber()))
            } else {
				// If no mutation is <= the MUTATION_RATE then the mutated
				// version of the given rocket's genes are just the rocket's
				// genes.
				mutatedGenes.append(rocket.getGenes()[i])
            }
        }
        mutatedRocket.setGenes(genesArray: mutatedGenes)
        return mutatedRocket;
    }
    
    // The mutatePopulation takes in a population and returns a mutated version
    // of that population.
    func mutatePopulation(population: [Rocket]) -> [Rocket] {
        // This is creating a new population object which will have the given
        // population's rockets applied with mutation.
        var mutatedPopulation: [Rocket] = []
        // This is looping through the population's rockets and grapping that
        // rocket, mutating it, and adding it to the new population.
        for i in 0..<population.count {
            // This grabs the populations rocket, applies the mutateRocket
            // function to it, and adds the mutated version to the new
            // mutatedPopulation.
            mutatedPopulation.append(mutateRocket(rocket: population[i]))
        }
        return mutatedPopulation;
    }
    
    func matingPoolByFitness(population: [Rocket]) -> [Rocket] {
        // This is creating a new matingPool population of the TOURNAMENT_SIZE.
        var matingPool: [Rocket] = []
        // This loops through the new population and testing the randomly picked
        // rockets. If a rocket has succesfully passed the test than the it's
        // added to the pool and the while loop stops, but while it hasn't it
        // will be picking a new rocket and testing it.
        for _ in 0..<TOURNAMENT_SELECTION_SIZE {
            // This is picking a randomRocket by mapping the randomNumber
            // between 0-1 to 0-population's size.
            var randomRocket = population[(Int) (Math().map(value: Float(drand48()), valMin: 0, valMax: 1, mapMin: 0,
                                                            mapMax: Float(population.count - 1)))];
            // This is picking out a randomNumber between 0-1 and mapping it to
            // 0-maxFitness
            let randomNumber = Math().map(value: Float(drand48()), valMin: 0, valMax: 1, mapMin: 0, mapMax: Float(maxFitness));
            // While it hasn't picked out a rocket that passed the test it will
            // pick a new rocket and keep testing, however if it does
            // successfully pick out a rocket then that rocket will be added to
            // the mating pool and the while loop will stop.
            while (true) {
                // This is testing the randomRocket
                if CGFloat(randomNumber) <= randomRocket.getFitness() {
                    // This is adding the rocket to the new population
                    matingPool.append(randomRocket)
                    // This stopping the loop if the randomRocket passed the if
                    // statement's conditional.
                    break;
                }
                // This is picking out a new randomRocket
                randomRocket = population[(Int) (Math().map(value: Float(drand48()), valMin: 0, valMax: 1, mapMin: 0,
                                                            mapMax: Float(population.count)))];
            }
        }
        // This is sorting the rocket so the crossoverPopulation picks the best
        // rocket that passed the test out of the population's size (or
        // TOURNAMENT_SIZE which as of now is 4).
        matingPool = self.sortRocketsByFitness(rocketArray: matingPool)
        return matingPool;
    }
    
    // This is a simple bubble sort algorithm sorting from greatest to least.
    // What's going on is that first a for loop of int h has to run these two
    // other for loops to sort every index of the array
    // The array in this case is the 'chromosomes' array. In for loop of int i
    // it starts at the end of the array
    // to see if any value before that (at index j) might be smaller (might have
    // a worse fitness score)
    // in for loop of int j it stops at i because in for loop at i it has
    // already run j to see if index i is the smallest fitness score
    // basically the reason j stops at i is because i is already sorted so it
    // doesn't need to test the other values.
    // in for loop of int j it tests to see if the fitness score of j is < the
    // fitness score of i.
    // If the condition is true, it swaps the values.
    func sortRocketsByFitness(rocketArray: [Rocket]) -> [Rocket] {
        var sortedRocketArray: [Rocket] = rocketArray
        for i in stride(from: rocketArray.count - 1, to: 0, by: -1) {
            for j in stride(from: 0, to: i, by: +1) {
                    // The condition tests to see if the fitness score of j is <
                    // the fitness score i. If the condition is true
                    // it has to swap the values by storing one of the values in
                    // a temporary variable.
                    // I would like to point out that to be 100% certain
                    // that there will be no errors,
                    // you might want to TEST j and i
                    // but you'd want to SWAP j and j + 1, not j and i.
                if sortedRocketArray[j].getFitness() < sortedRocketArray[i].getFitness() {
                    let temp = sortedRocketArray[j];
                    sortedRocketArray[j] = sortedRocketArray[i];
                    sortedRocketArray[i] = temp;
                }
            }
        }
        return sortedRocketArray
    }
    
    func calculateHighestFitness(population: [Rocket]) {
        maxFitness = 0;
        // This is looping through the given generation's rockets and seeing if
        // any of their fitness scores are higher than the maxFitness (which is
        // 0), if it is, then the maxFitness is set to that fitness.
        for i in 0..<population.count {
            if population[i].getFitness() > maxFitness {
                // This is declaring the maxFitness to be that rocket's fitness
                // score.
                maxFitness = population[i].getFitness();
            }
        }
    }
}

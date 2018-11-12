//
//  GameViewController.swift
//  SmartRockets
//
//  Created by Julian Abhari on 1/7/17.
//  Copyright © 2017 Julian Abhari. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import AVFoundation

class GameViewController: UIViewController {
    
    static var levelData: [String: [String]] = [:]
    static var numOfObstacles: Int = 1
    static var gameAudioPlayer: AVAudioPlayer?
    
    @IBOutlet var doneButton: UIButton!
    @IBOutlet var addInstruction: UILabel!
    @IBOutlet var addObstacleButton: UIButton!
    @IBOutlet var deleteInstruction: UILabel!
    @IBOutlet var deleteButton: UIButton!
    
    @IBAction func addNewObstacle(_ sender: Any) {
        GameScene.isAddingObstacle = true
        let delay = 3.00 * Double(NSEC_PER_SEC)
        let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time) {
            self.addInstruction.isHidden = true
        }
        addInstruction.isHidden = false
    }
    
    @IBAction func deleteObstacle(_ sender: Any) {
        GameScene.isDeletingObstacle = true
        let delay = 3.00 * Double(NSEC_PER_SEC)
        let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time) {
            self.deleteInstruction.isHidden = true
        }
        deleteInstruction.isHidden = false
    }
    
    
    @IBAction func hasFinished(_ sender: Any) {
        var arrayOfStringCGPoints: [String] = []
        
        // Prepare levelData for saving
        
        for i in 0..<GameViewController.numOfObstacles {
            arrayOfStringCGPoints.append(NSStringFromCGPoint(GameScene.obstacles[i].position))
        }
        arrayOfStringCGPoints.append(NSStringFromCGPoint(GameScene.target!.position))
        
        
        GameViewController.levelData[LevelViewController.levelName!] = arrayOfStringCGPoints
        
        // Save levelData
        let LevelDataDefault = UserDefaults.standard
        LevelDataDefault.set(GameViewController.levelData, forKey: "levelData")
        LevelDataDefault.synchronize()
        
        addObstacleButton.isHidden = true
        deleteButton.isHidden = true
        doneButton.isHidden = true
    }
    
    @IBAction func goBack(_ sender: Any) {
        var arrayOfStringCGPoints: [String] = []
        
        for i in 0..<GameViewController.numOfObstacles {
            arrayOfStringCGPoints.append(NSStringFromCGPoint(GameScene.obstacles[i].position))
        }
        arrayOfStringCGPoints.append(NSStringFromCGPoint(GameScene.target!.position))
        
        // Prepare levelData for saving
        GameViewController.levelData[LevelViewController.levelName!] = arrayOfStringCGPoints

        // Save levelData
        let LevelDataDefault = UserDefaults.standard
        LevelDataDefault.set(GameViewController.levelData, forKey: "levelData")
        LevelDataDefault.synchronize()
        GameViewController.levelData = LevelDataDefault.value(forKey: "levelData") as! [String: [String]]
        
        GameScene.hasFinishedLevelCreation = false
        GameViewController.numOfObstacles = 1
        
        GameViewController.gameAudioPlayer?.stop()
        GameViewController.gameAudioPlayer = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Start Loading level
        let LevelDataDefault = UserDefaults.standard
        
        if UserDefaults.standard.object(forKey: "levelData") != nil {
            GameViewController.levelData = LevelDataDefault.value(forKey: "levelData") as! [String: [String]]
            
            if GameViewController.levelData[LevelViewController.levelName!] != nil {
                GameViewController.numOfObstacles = GameViewController.levelData[LevelViewController.levelName!]!.count - 1
            }
        }
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            view.showsFPS = false
            view.showsNodeCount = false
        }
        // Loading saved levelData
        if GameViewController.levelData[LevelViewController.levelName!] != nil {

            for i in 0..<GameViewController.numOfObstacles {
                GameScene.obstacles[i].position = CGPointFromString((GameViewController.levelData[LevelViewController.levelName!]?[i])!)
            }
            GameScene.target!.position = CGPointFromString((GameViewController.levelData[LevelViewController.levelName!]?[GameViewController.numOfObstacles])!)
        }
        
        do {
            if GameViewController.gameAudioPlayer == nil {
                if LevelViewController.levelName!.caseInsensitiveCompare("shh...") == ComparisonResult.orderedSame {
                    GameViewController.gameAudioPlayer = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "shh..", ofType: "m4a")!))
                } else {
                    GameViewController.gameAudioPlayer = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "Ominous Uprising", ofType: "m4a")!))
                }
                GameViewController.gameAudioPlayer?.numberOfLoops = -1
                GameViewController.gameAudioPlayer?.prepareToPlay()
            } else {
                addObstacleButton.isHidden = true
                deleteButton.isHidden = true
                doneButton.isHidden = true
            }
        }
        catch {
            print("No sound found by URL: \(error)")
        }
    }
    
    static func deleteLevelAtIndex(levelName: String) {
        levelData.removeValue(forKey: levelName)
        
        let LevelDataDefault = UserDefaults.standard
        LevelDataDefault.set(levelData, forKey: "levelData")
        LevelDataDefault.synchronize()
        
        GameViewController.levelData = LevelDataDefault.value(forKey: "levelData") as! [String: [String]]
        PopulationViewController.deletePopulationAtIndex(levelName: levelName)
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}

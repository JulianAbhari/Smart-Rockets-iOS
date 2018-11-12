//
//  PopulationViewController.swift
//  SmartRockets
//
//  Created by Julian Abhari on 6/22/17.
//  Copyright © 2017 Julian Abhari. All rights reserved.
//

import Foundation
import UIKit

class PopulationViewController: UIViewController {
    
    static var populationSize: Int = 0
    static var mutationRate: Float = 0
    static var wallBoundary: Bool = true
    static var damageIfCrash: Bool = false
    static var damageIfHitWall: Bool = false
    
    static var populationData: [String: [String]] = [:]
    
    @IBOutlet var populationSlider: UISlider!
    @IBOutlet var populationLabel: UILabel!
    
    @IBAction func adjustPopulationSize(_ sender: Any) {
        populationLabel.text! = String(Int(populationSlider.value))
        PopulationViewController.populationSize = Int(populationLabel.text!)!
    }
    
    @IBOutlet var mutationSlider: UISlider!
    @IBOutlet var mutationLabel: UILabel!
    
    @IBAction func adjustMutationRate(_ sender: Any) {
        mutationLabel.text! = String(Float(round(mutationSlider.value * 100.0) / 100.0))
        PopulationViewController.mutationRate = Float(mutationLabel.text!)!
    }
    
    
    @IBOutlet var boundaryS: UISwitch!
    @IBOutlet var crashS: UISwitch!
    @IBOutlet var hitWallS: UISwitch!
    
    
    @IBAction func wallBoundarySwitch(_ sender: UISwitch) {
        if sender.isOn == true {
            PopulationViewController.wallBoundary = true
        } else {
            PopulationViewController.wallBoundary = false
        }
    }
    
    @IBAction func crashSwitch(_ sender: UISwitch) {
        if sender.isOn == true {
            PopulationViewController.damageIfCrash = true
        } else {
            PopulationViewController.damageIfCrash = false
        }
    }
    
    @IBAction func hitWallSwitch(_ sender: UISwitch) {
        if sender.isOn == true {
            PopulationViewController.damageIfHitWall = true
        } else {
            PopulationViewController.damageIfHitWall = false
        }
    }
    
    @IBAction func hasFinished(_ sender: Any) {
        var tempPopulationData: [String] = []
        tempPopulationData.append(String(PopulationViewController.populationSize))
        tempPopulationData.append(String(PopulationViewController.mutationRate))
        tempPopulationData.append(String(PopulationViewController.wallBoundary))
        tempPopulationData.append(String(PopulationViewController.damageIfCrash))
        tempPopulationData.append(String(PopulationViewController.damageIfHitWall))
        
        // Prepare populationData for saving
        PopulationViewController.populationData[LevelViewController.levelName!] = tempPopulationData
        
        // Save population data
        let PopulationDataDefault = UserDefaults.standard
        PopulationDataDefault.set(PopulationViewController.populationData, forKey: "populationData")
        PopulationDataDefault.synchronize()
        
        TitleViewController.audioPlayer?.stop()
        GameViewController.gameAudioPlayer?.play()
        GameScene.hasFinishedLevelCreation = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let PopulationDataDefault = UserDefaults.standard
        
        if UserDefaults.standard.object(forKey: "populationData") != nil {
            PopulationViewController.populationData = PopulationDataDefault.value(forKey: "populationData") as! [String: [String]]
            if PopulationViewController.populationData[LevelViewController.levelName!] != nil {
                // Load Population Data
                populationSlider.value = Float(PopulationViewController.populationData[LevelViewController.levelName!]![0])!
                mutationSlider.value = Float(PopulationViewController.populationData[LevelViewController.levelName!]![1])!
                boundaryS.isOn = Bool(PopulationViewController.populationData[LevelViewController.levelName!]![2])!
                crashS.isOn = Bool(PopulationViewController.populationData[LevelViewController.levelName!]![3])!
                hitWallS.isOn = Bool(PopulationViewController.populationData[LevelViewController.levelName!]![4])!
            }
            
        }
        
        populationLabel.text! = String(Int(populationSlider.value))
        PopulationViewController.populationSize = Int(populationLabel.text!)!
        mutationLabel.text! = String(Float(round(mutationSlider.value * 100.0) / 100.0))
        PopulationViewController.mutationRate = Float(mutationLabel.text!)!
        PopulationViewController.wallBoundary = boundaryS.isOn
        PopulationViewController.damageIfCrash = crashS.isOn
        PopulationViewController.damageIfHitWall = hitWallS.isOn
    }
    
    static func deletePopulationAtIndex(levelName: String) {
        PopulationViewController.populationData.removeValue(forKey: levelName)
        
        let PopulationDataDefault = UserDefaults.standard
        PopulationDataDefault.set(PopulationViewController.populationData, forKey: "populationData")
        PopulationDataDefault.synchronize()
        
       PopulationViewController.populationData = PopulationDataDefault.value(forKey: "populationData") as! [String: [String]]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

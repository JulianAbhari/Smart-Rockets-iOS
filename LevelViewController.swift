//
//  LevelViewController.swift
//  SmartRockets
//
//  Created by Julian Abhari on 5/25/17.
//  Copyright © 2017 Julian Abhari. All rights reserved.
//

import Foundation
import UIKit

class LevelViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var textField: UITextField!
    @IBOutlet var table: UITableView!
    
    @IBAction func addNewLevel(_ sender: Any) {
        textField.isHidden = false
        moveTextField(textField: textField, moveDistance: -250, isUp: true)
    }
    
   static  var levelName: String?
    var levelNames: [String] = []
    
    override func viewDidLoad() {
        // Do any additional setup after loading the view, typically from a nib
        super.viewDidLoad()
        let LevelNamesDefault = UserDefaults.standard
        if UserDefaults.standard.object(forKey: "levelNames") != nil {
            levelNames = LevelNamesDefault.value(forKey: "levelNames") as! [String]
        }
        self.table.reloadData()
        textField.isHidden = true
        
        if !TitleViewController.audioPlayer!.isPlaying {
            TitleViewController.audioPlayer?.currentTime = 0
            TitleViewController.audioPlayer?.play()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return levelNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // TableView manage CellsAtIndexPath
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        let label = cell?.viewWithTag(0) as! UILabel
        label.text = levelNames[indexPath.row]
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        LevelViewController.levelName = levelNames[indexPath.row]
        performSegue(withIdentifier: "segue", sender: self)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            GameViewController.deleteLevelAtIndex(levelName: levelNames[indexPath.row])
            levelNames.remove(at: indexPath.row)
            
            // Re save levelNames
            let LevelNamesDefault = UserDefaults.standard
            LevelNamesDefault.set(levelNames, forKey: "levelNames")
            LevelNamesDefault.synchronize()
            tableView.reloadData()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        moveTextField(textField: textField, moveDistance: -250, isUp: false)
        textField.isHidden = true
        levelNames.append(textField.text!)
        
        // Update Table Data
        table.beginUpdates()
        table.insertRows(at: [
            IndexPath(row: levelNames.count-1, section: 0)
            ], with: .automatic)
        table.endUpdates()
        
        // Save levelNames
        let LevelNamesDefault = UserDefaults.standard
        LevelNamesDefault.set(levelNames, forKey: "levelNames")
        LevelNamesDefault.synchronize()
    }
    
    func moveTextField(textField: UITextField, moveDistance: Int, isUp: Bool) {
        let moveDuration = 0.3
        let movement: CGFloat = CGFloat(isUp ? moveDistance : -moveDistance)
        
        UIView.beginAnimations("animateTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(moveDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

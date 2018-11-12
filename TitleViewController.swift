//
//  TitleViewController.swift
//  SmartRockets
//
//  Created by Julian Abhari on 6/7/17.
//  Copyright © 2017 Julian Abhari. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class TitleViewController: UIViewController {
    static var audioPlayer: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            if TitleViewController.audioPlayer == nil {
                
                TitleViewController.audioPlayer = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "Something Stranger This Way Comes", ofType: "m4a")!))
                TitleViewController.audioPlayer?.numberOfLoops = -1
                TitleViewController.audioPlayer?.prepareToPlay()
            }
            
            
        } catch {
            print("No sound found by URL: \(error)")
        }
        if !(TitleViewController.audioPlayer?.isPlaying)! {
            TitleViewController.audioPlayer?.play()
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

//
//  PlayViewController.swift
//  iOS Tetris
//
//  Created by Josh Feltman on 4/24/19.
//  Copyright © 2019 Josh Feltman. All rights reserved.
//

import Foundation
import UIKit

class PlayViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func levelOneTapped(_ sender: UIButton) {
        // Perform segue
        performSegue(withIdentifier: "levelOneSegue", sender: nil)
    }
    
    @IBAction func levelTwoTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "levelTwoSegue", sender: nil)
    }
    
    @IBAction func levelThreeTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "levelThreeSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "levelOneSegue") {
            let gameVC = segue.destination as! GameViewController
            gameVC.startingDifficulty = 1
        } else if (segue.identifier == "levelTwoSegue") {
            let gameVC = segue.destination as! GameViewController
            gameVC.startingDifficulty = 2
        } else if (segue.identifier == "levelThreeSegue") {
            let gameVC = segue.destination as! GameViewController
            gameVC.startingDifficulty = 3
        }
    }
}

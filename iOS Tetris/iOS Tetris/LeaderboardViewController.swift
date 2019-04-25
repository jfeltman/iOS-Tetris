//
//  LeaderboardViewController.swift
//  iOS Tetris
//
//  Created by Josh Feltman on 4/24/19.
//  Copyright © 2019 Josh Feltman. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class LeaderboardViewController: UIViewController {
    
    var managedObjectContext: NSManagedObjectContext!
    var appDelegate: AppDelegate!
    
    // score labels
    @IBOutlet weak var scoreOne: UILabel!
    @IBOutlet weak var scoreTwo: UILabel!
    @IBOutlet weak var scoreThree: UILabel!
    @IBOutlet weak var scoreFour: UILabel!
    @IBOutlet weak var scoreFive: UILabel!
    @IBOutlet weak var scoreSix: UILabel!
    @IBOutlet weak var scoreSeven: UILabel!
    @IBOutlet weak var scoreEight: UILabel!
    @IBOutlet weak var scoreNine: UILabel!
    @IBOutlet weak var scoreTen: UILabel!
    
    var scoreLabels: [UILabel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // JOSH - core data
        self.appDelegate = UIApplication.shared.delegate as? AppDelegate
        self.managedObjectContext = appDelegate.persistentContainer.viewContext
        
        initScoreLabels()
        getTopTenScores()
    }
    
    func getTopTenScores() {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ScoreEntity")
        var scores: [NSManagedObject]!
        do {
            scores = try self.managedObjectContext.fetch(fetchRequest)
        } catch {
            print("leaderboard error: \(error)")
        }
        
        var allScores: [Int] = []
        
        for score in scores {
            let s = score.value(forKey: "score") as! Int
            allScores.append(s)
        }
        
        // Sort the scores, then reverse them to get the highest scores in the front of the list
        allScores.sort()
        allScores.reverse()
        
        // Get the top 10 scores (or however many there are if there is less than 10)
        for i in 0..<allScores.count {
            if (i == 10) {
                break
            }
            
            scoreLabels[i].text = "\(i + 1). \(allScores[i])"
            scoreLabels[i].isHidden = false
        }
    }
    
    func initScoreLabels() {
        scoreLabels = [scoreOne, scoreTwo, scoreThree, scoreFour, scoreFive, scoreSix, scoreSeven, scoreEight, scoreNine, scoreTen]
        
        for score in scoreLabels {
            score.isHidden = true
        }
    }
}


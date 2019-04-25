//
//  GameViewController.swift
//  iOS Tetris
//
//  Created by Josh Feltman on 4/3/19.
//  Copyright © 2019 Josh Feltman. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import CoreData
import AVFoundation

class GameViewController: UIViewController, GameEngineDelegate, UIGestureRecognizerDelegate {
    
    var scene: GameScene!
    var gameEngine: GameEngine!
    var panPointReference: CGPoint?
    
    var startingDifficulty: Int!
    var managedObjectContext: NSManagedObjectContext!
    var appDelegate: AppDelegate!
    var audioPlayer: AVAudioPlayer!
    
    let musicURL = Bundle.main.url(forResource: "theme.mp3", withExtension: nil)

    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var nextLabel: UILabel!
    @IBOutlet weak var gameOverLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // JOSH - core data
        self.appDelegate = UIApplication.shared.delegate as? AppDelegate
        self.managedObjectContext = appDelegate.persistentContainer.viewContext
        
        // hide game over label
        gameOverLabel.isHidden = true
        
        // Play background music
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: musicURL!)
        } catch {
            print("error accessing music")
        }
        audioPlayer.volume = 0.25
        audioPlayer.numberOfLoops = -1 // loop forever
        
        // configure the view
        let skView = view as! SKView
        skView.isMultipleTouchEnabled = false
        
        // create and configure the scene
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .aspectFill
        
        scene.tick = didTick
        
        gameEngine = GameEngine()
        gameEngine.delegate = self
        
        gameEngine.beginGame()
        
        // JOSH - set game level
        setGameLevel(gameEngine: gameEngine)
        
        // Present the scene
        skView.presentScene(scene)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch = touches.first!
        let positionInScene = touch.location(in: scene)
        let touchedNode = scene.atPoint(positionInScene)
        
        if let name = touchedNode.name
        {
            // Check if hold area has been tapped
            if name == "holdArea"
            {
                print("Touched")
                //scene.stopTicking()
                //self.shapeWasHeld()
            }
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func userDidTap(_ sender: UITapGestureRecognizer) {
        if (gameEngine.gameOver == false) {
            gameEngine.rotateShape()
        } else {
            performSegue(withIdentifier: "menuSegue", sender: nil)
        }
    }
    
    @IBAction func userDidPan(_ sender: UIPanGestureRecognizer) {
        let currentPoint = sender.translation(in: self.view)
        
        if let originalPoint = panPointReference {
            // check if x coordinate has crossed threshold (90% of blocksize)
            if abs(currentPoint.x - originalPoint.x) > (BlockSize * 0.9) {
                // Check velocity to determine left or right
                if sender.velocity(in: self.view).x > CGFloat(0) {
                    // positive velocity, move right
                    gameEngine.moveShapeRight()
                    panPointReference = currentPoint
                } else {
                    // negative velocity, move left
                    gameEngine.moveShapeLeft()
                    panPointReference = currentPoint
                }
            }
        } else if sender.state == .began {
            panPointReference = currentPoint
        }
    }
    
    @IBAction func userDidSwipe(_ sender: UISwipeGestureRecognizer) {
        gameEngine.dropShape()
    }
    
    // Optional delegate method
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool
    {
        return true
    }
    
    // Optional delegate method to deal with interaction of multiple gestures
    // Tap > Pan > Swipe
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool
    {
        if gestureRecognizer is UISwipeGestureRecognizer {
            if otherGestureRecognizer is UIPanGestureRecognizer {
                return true
            }
        } else if gestureRecognizer is UIPanGestureRecognizer {
            if otherGestureRecognizer is UITapGestureRecognizer {
                return true
            }
        }
        return false
    }
    
    // Lowers shape by 1 row and redraws the shape
    func didTick() {
        gameEngine.letShapeFall()
    }
    
    func nextShape() {
        let newShapes = gameEngine.newShape()
        guard let fallingShape = newShapes.fallingShape else {
            return
        }
        
        self.scene.addPreviewShapeToScene(shape: newShapes.nextShape!) {}
        self.scene.movePreviewShape(shape: fallingShape) {
            self.view.isUserInteractionEnabled = true
            self.scene.startTicking()
        }
    }
    
    // JOSH START
    func shapeWasHeld() {
//        let newShapes = gameEngine.holdFallingShape()
//        guard let fallingShape = newShapes.fallingShape else {
//            return
//        }
        gameEngine.holdShape = gameEngine.fallingShape!
        
        //self.scene.addPreviewShapeToScene(shape: newShapes.nextShape!) {}
        self.scene.addHoldShapeToScene(shape: gameEngine.holdShape!) {}
//
//        self.scene.movePreviewShape(shape: fallingShape) {
//            self.view.isUserInteractionEnabled = true
//            self.scene.startTicking()
//        }
    }
    // JOSH END
    
    func gameDidBegin(gameEngine: GameEngine) {
        audioPlayer.play()
        
        scoreLabel.text = "\(gameEngine.score)"
        levelLabel.text = "\(gameEngine.level)"
        scene.tickLengthMillis = TickLengthLevelOne
        
        // the following is false when restarting a new game
        if gameEngine.nextShape != nil && gameEngine.nextShape!.blocks[0].sprite == nil {
            scene.addPreviewShapeToScene(shape: gameEngine.nextShape!) {
                self.nextShape()
            }
        } else {
            nextShape()
        }
    }
    
    func gameDidEnd(gameEngine: GameEngine) {
        audioPlayer.pause()
        scene.playSound(sound: "gameover.mp3")
        
        view.isUserInteractionEnabled = false
        scene.stopTicking()

        print("FINAL SCORE: \(gameEngine.score)")
        saveScore(score: gameEngine.score)
        
        gameEngine.score = 0
        gameOverLabel.isHidden = false
    
        scene.animateCollapsingLines(linesToRemove: gameEngine.removeAllBlocks(),
                                     fallenBlocks: gameEngine.removeAllBlocks())
        {
            self.view.isUserInteractionEnabled = true
        }
        
    }
    
    func gameDidLevelUp(gameEngine: GameEngine) {
        levelLabel.text = "\(gameEngine.level)"
        
        if scene.tickLengthMillis >= 100 {
            scene.tickLengthMillis -= 100
        } else if scene.tickLengthMillis > 50 {
            scene.tickLengthMillis -= 50
        }
        
        scene.playSound(sound: "levelup.mp3")
    }
    
    func gameShapeDidDrop(gameEngine: GameEngine) {
        scene.stopTicking()
        scene.redrawShape(shape: gameEngine.fallingShape!) {
            gameEngine.letShapeFall()
        }
        
        scene.playSound(sound: "drop.mp3")
    }
    
    func gameShapeDidLand(gameEngine: GameEngine) {
        scene.stopTicking()
        
        self.view.isUserInteractionEnabled = false

        let removedLines = gameEngine.removeCompletedLines()
        if removedLines.linesRemoved.count > 0 {
            self.scoreLabel.text = "\(gameEngine.score)"
            scene.animateCollapsingLines(linesToRemove: removedLines.linesRemoved,
                                         fallenBlocks:removedLines.fallenBlocks)
            {
                self.gameShapeDidLand(gameEngine: gameEngine)
            }
            scene.playSound(sound: "bomb.mp3")
        } else {
            nextShape()
        }
    }
    
    func gameShapeDidMove(gameEngine: GameEngine) {
        scene.redrawShape(shape: gameEngine.fallingShape!) {}
    }
    
    // JOSH START
    func gameShapeHeld(gameEngine: GameEngine) {
    }
    
    func setGameLevel(gameEngine: GameEngine) {
        switch (startingDifficulty) {
        case 1:
            // do nothing
            break
        case 2:
            // Increase game level to level 4
            gameEngine.level = 4
            for _ in 1...4 {
                gameDidLevelUp(gameEngine: gameEngine)
            }
        case 3:
            // increase game level to level 8
            gameEngine.level = 8
            for _ in 1...8 {
                gameDidLevelUp(gameEngine: gameEngine)
            }
        default:
            break
        }
    }
    
    func saveScore(score: Int) {
        let newScore = NSEntityDescription.insertNewObject(forEntityName: "ScoreEntity", into: self.managedObjectContext)
        newScore.setValue(score, forKey: "score")

        self.appDelegate.saveContext()
    }
    // JOSH END
}

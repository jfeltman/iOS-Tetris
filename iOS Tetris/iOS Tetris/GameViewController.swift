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

class GameViewController: UIViewController, GameEngineDelegate, UIGestureRecognizerDelegate {
    
    var scene: GameScene!
    var gameEngine: GameEngine!
    var panPointReference: CGPoint?

    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        // Present the scene
        skView.presentScene(scene)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func userDidTap(_ sender: UITapGestureRecognizer) {
        gameEngine.rotateShape()
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
    
    func gameDidBegin(gameEngine: GameEngine) {
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
        view.isUserInteractionEnabled = false
        scene.stopTicking()

        scene.animateCollapsingLines(linesToRemove: gameEngine.removeAllBlocks(),
                                     fallenBlocks: gameEngine.removeAllBlocks()) {
            gameEngine.beginGame()
        }
        
    }
    
    func gameDidLevelUp(gameEngine: GameEngine) {
        levelLabel.text = "\(gameEngine.level)"
        
        if scene.tickLengthMillis >= 100 {
            scene.tickLengthMillis -= 100
        } else if scene.tickLengthMillis > 50 {
            scene.tickLengthMillis -= 50
        }
        
        //scene.playSound(sound: "Sounds/levelup.mp3")
    }
    
    func gameShapeDidDrop(gameEngine: GameEngine) {
        scene.stopTicking()
        scene.redrawShape(shape: gameEngine.fallingShape!) {
            gameEngine.letShapeFall()
        }
        
        //scene.playSound(sound: "Sounds/drop.mp3")
    }
    
    func gameShapeDidLand(gameEngine: GameEngine) {
        scene.stopTicking()
        
        self.view.isUserInteractionEnabled = false

        let removedLines = gameEngine.removeCompletedLines()
        if removedLines.linesRemoved.count > 0 {
            self.scoreLabel.text = "\(gameEngine.score)"
            scene.animateCollapsingLines(linesToRemove: removedLines.linesRemoved,
                                         fallenBlocks:removedLines.fallenBlocks) {
                // #11
                self.gameShapeDidLand(gameEngine: gameEngine)
            }
            //scene.playSound(sound: "Sounds/bomb.mp3")
        } else {
            nextShape()
        }
    }
    
    func gameShapeDidMove(gameEngine: GameEngine) {
        scene.redrawShape(shape: gameEngine.fallingShape!) {}
    }
}

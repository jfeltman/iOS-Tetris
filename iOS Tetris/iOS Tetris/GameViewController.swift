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

class GameViewController: UIViewController {
    
    var scene: GameScene!
    var gameEngine: GameEngine!

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
        gameEngine.beginGame()
        
        // Present the scene
        skView.presentScene(scene)
        
        scene.addPreviewShapeToScene(shape: gameEngine.nextShape!) {
            // Move preview shape to starting position
            self.gameEngine.nextShape?.moveTo(column: StartingColumn, row: StartingRow)
            
            // Start moving the shape
            self.scene.movePreviewShape(shape: self.gameEngine.nextShape!) {
                // create next shape
                let nextShapes = self.gameEngine.newShape()
                self.scene.startTicking()
                
                // add next shape as preview
                self.scene.addPreviewShapeToScene(shape: nextShapes.nextShape!) {}
            }
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // Lowers shape by 1 row and redraws the shape
    func didTick() {
        gameEngine.fallingShape?.lowerShapeByOneRow()
        scene.redrawShape(shape: gameEngine.fallingShape!, completion: {})
    }
}

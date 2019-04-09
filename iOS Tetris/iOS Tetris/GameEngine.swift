//
//  GameEngine.swift
//  iOS Tetris
//
//  Created by Josh Feltman on 4/9/19.
//  Copyright © 2019 Josh Feltman. All rights reserved.
//

import SpriteKit

let NumColumns = 10
let NumRows = 20

let StartingColumn = 4
let StartingRow = 0

let PreviewColumn = 12
let PreviewRow = 1

class GameEngine {
    var blockArray: Array2D<Block>
    var nextShape: Shape?
    var fallingShape: Shape?
    
    init() {
        fallingShape = nil
        nextShape = nil
        blockArray = Array2D<Block>(columns: NumColumns, rows: NumRows)
    }
    
    // Start game, create the next shape
    func beginGame() {
        if (nextShape == nil) {
            nextShape = Shape.random(startingColumn: PreviewColumn, startingRow: PreviewRow)
        }
    }
    
    // Switches preview shape with the falling shape and moves it to the starting position, then creates a new next shape
    func newShape() -> (fallingShape: Shape?, nextShape: Shape?) {
        fallingShape = nextShape
        nextShape = Shape.random(startingColumn: PreviewColumn, startingRow: PreviewRow)
        fallingShape?.moveTo(column: StartingColumn, row: StartingRow)
        return (fallingShape, nextShape)
    }
}

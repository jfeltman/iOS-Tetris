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

let PointsPerLine = 10
let LevelThreshold = 500

class GameEngine {
    var blockArray: Array2D<Block>
    var nextShape: Shape?
    var fallingShape: Shape?
    var delegate: GameEngineDelegate?
    
    var score = 0
    var level = 1
    
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
        
        delegate?.gameDidBegin(gameEngine: self)
    }
    
    // Switches preview shape with the falling shape and moves it to the starting position, then creates a new next shape
    func newShape() -> (fallingShape: Shape?, nextShape: Shape?) {
        fallingShape = nextShape
        nextShape = Shape.random(startingColumn: PreviewColumn, startingRow: PreviewRow)
        fallingShape?.moveTo(column: StartingColumn, row: StartingRow)
        
        guard detectIllegalPlacement() == false else {
            // If shape is at the starting position and collides with another block, the user has lost and the game is over
            nextShape = fallingShape
            nextShape!.moveTo(column: PreviewColumn, row: PreviewRow)
            endGame()
            return (nil, nil)
        }
        
        return (fallingShape, nextShape)
    }
    
    // Checks block boundary conditions
    func detectIllegalPlacement() -> Bool {
        guard let shape = fallingShape else {
            return false
        }
        
        for block in shape.blocks {
            // Check if block exceeds the legal size of the game board
            if block.column < 0 || block.column >= NumColumns ||
                block.row < 0 || block.row >= NumRows {
                return true
            } else if blockArray[block.column, block.row] != nil {
                // if block is placed on top of an already existing block
                return true
            }
        }
        
        return false
    }
    
    // Drop shape to bottom of legal game board
    func dropShape() {
        guard let shape = fallingShape else {
            return
        }
        
        while detectIllegalPlacement() == false {
            shape.lowerShapeByOneRow()
        }
        
        shape.raiseShapeByOneRow()
        delegate?.gameShapeDidDrop(gameEngine: self)
    }
    
    // Makes the shape automatically fall, will be called every tick
    func letShapeFall() {
        guard let shape = fallingShape else {
            return
        }
        
        shape.lowerShapeByOneRow()
        if detectIllegalPlacement() == true {
            // illegal move, revert shape back up by 1 row
            shape.raiseShapeByOneRow()
            
            // if shape is still illegal, it means the player has lost the game
            if detectIllegalPlacement() {
                endGame()
            } else {
                settleShape()
            }
        } else {
            delegate?.gameShapeDidMove(gameEngine: self)
            
            if detectTouch() {
                settleShape()
            }
        }
    }
    
    func rotateShape() {
        guard let shape = fallingShape else {
            return
        }
        
        shape.rotateClockwise()
        guard detectIllegalPlacement() == false else {
            // could not rotate shape, so revert it
            shape.rotateCounterClockwise()
            return
        }
        delegate?.gameShapeDidMove(gameEngine: self)
    }
    
    func moveShapeLeft() {
        guard let shape = fallingShape else {
            return
        }
        shape.shiftLeftByOneColumn()
        guard detectIllegalPlacement() == false else {
            // could not move shape left, so move it back right
            shape.shiftRightByOneColumn()
            return
        }
        delegate?.gameShapeDidMove(gameEngine: self)
    }
    
    func moveShapeRight() {
        guard let shape = fallingShape else {
            return
        }
        shape.shiftRightByOneColumn()
        guard detectIllegalPlacement() == false else {
            // could not move shape right, revert it left by 1
            shape.shiftLeftByOneColumn()
            return
        }
        delegate?.gameShapeDidMove(gameEngine: self)
    }
    
    func settleShape() {
        guard let shape = fallingShape else {
            return
        }
        
        // Shape has landed, set each block in shape to its corresponding spot in the game board
        for block in shape.blocks {
            blockArray[block.column, block.row] = block
        }
        
        // Nullify falling shape since it is now apart of the gameboard
        fallingShape = nil
        delegate?.gameShapeDidLand(gameEngine: self)
    }
    
    func detectTouch() -> Bool {
        guard let shape = fallingShape else {
            return false
        }
        
        for bottomBlock in shape.bottomBlocks {
            if (bottomBlock.row == NumRows - 1 ||
                blockArray[bottomBlock.column, bottomBlock.row + 1] != nil)
            {
                return true
            }
        }
        
        return false
    }
    
    func endGame() {
        score = 0
        level = 1
        delegate?.gameDidEnd(gameEngine: self)
    }
    
    // Delete row when a horizontal line has been filled with blocks
    func removeCompletedLines() -> (linesRemoved: Array<Array<Block>>, fallenBlocks: Array<Array<Block>>)
    {
        var removedLines = Array<Array<Block>>()
        
        for row in (1 ..< NumRows).reversed() {
            var rowOfBlocks = Array<Block>()
            
            // iterate through each column, checking if a block exists in each column
            for column in 0 ..< NumColumns {
                guard let block = blockArray[column, row] else {
                    // if no block continue to next column
                    continue
                }
                rowOfBlocks.append(block)
            }
            // If rows of blocks array equals 10 (numColumns), remove that row
            if rowOfBlocks.count == NumColumns {
                removedLines.append(rowOfBlocks)
                for block in rowOfBlocks {
                    blockArray[block.column, block.row] = nil
                }
            }
        }
        
        // check if any lines have been removed, if not return
        if removedLines.count == 0 {
            return ([], [])
        }
        
        // Calculate the amount of points earned
        let pointsEarned = removedLines.count * PointsPerLine * level
        score += pointsEarned
        
        // if score goes over (leve * threshold), increase the level
        if score >= level * LevelThreshold {
            level += 1
            delegate?.gameDidLevelUp(gameEngine: self)
        }
        
        var fallenBlocks = Array<Array<Block>>()
        for column in 0 ..< NumColumns {
            var fallenBlocksArray = Array<Block>()
            
            // Starting at the leftmost column and the row above the bottom-most removed line
            for row in (1 ..< removedLines[0][0].row).reversed() {
                guard let block = blockArray[column, row] else {
                    continue
                }
                
                // JOSH START
                // Make new row the row plus however many lines are getting removed
                // Changed from Swiftris were every block get moved down no matter its previous position
                let newRow = row + removedLines.count
                // JOSH END
                
                block.row = newRow
                blockArray[column, row] = nil
                blockArray[column, newRow] = block
                fallenBlocksArray.append(block)
            }
            
            if fallenBlocksArray.count > 0 {
                fallenBlocks.append(fallenBlocksArray)
            }
        }
        return (removedLines, fallenBlocks)
    }
    
    func removeAllBlocks() -> Array<Array<Block>>
    {
        var allBlocks = Array<Array<Block>>()
        for row in 0 ..< NumRows {
            var rowOfBlocks = Array<Block>()
            for column in 0 ..< NumColumns {
                guard let block = blockArray[column, row] else {
                    continue
                }
                
                rowOfBlocks.append(block)
                blockArray[column, row] = nil
            }
            allBlocks.append(rowOfBlocks)
        }
        return allBlocks
    }
    
}

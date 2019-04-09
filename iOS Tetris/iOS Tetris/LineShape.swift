//
//  LineShape.swift
//  iOS Tetris
//
//  Created by Josh Feltman on 4/9/19.
//  Copyright © 2019 Josh Feltman. All rights reserved.
//

import SpriteKit

class LineShape: Shape {
    /*
     Orientation 0 and 180:
       | 0•|
       | 1 |
       | 2 |
       | 3 |
     
     Orientation 90 and 270:
     | 0 |•1 | 2 | 3 |
     
     
     • marks the row/column indicator for the shape
     */
    
    override var blockRowColumnPositions: [Orientation: Array<(columnDiff: Int, rowDiff: Int)>]
    {
        return [
            Orientation.Zero: [(0, 0), (1, 0), (2, 0), (3, 0)],
            Orientation.Ninety: [(-1, 0), (0, 0), (1, 0), (2, 0)],
            Orientation.OneEighty: [(0, 0), (1, 0), (2, 0), (3, 0)],
            Orientation.TwoSeventy: [(-1, 0), (0, 0), (1, 0), (2, 0)]
        ]
    }
    
    override var bottomBlocksForOrientations: [Orientation: Array<Block>] {
        return [
            Orientation.Zero:       [ blocks[FourthBlockIdx]],
            Orientation.Ninety:     [blocks[FirstBlockIdx], blocks[SecondBlockIdx], blocks[ThirdBlockIdx], blocks[FourthBlockIdx]],
            Orientation.OneEighty:  [blocks[FourthBlockIdx]],
            Orientation.TwoSeventy: [blocks[FirstBlockIdx], blocks[SecondBlockIdx], blocks[ThirdBlockIdx], blocks[FourthBlockIdx]]
        ]
    }
}
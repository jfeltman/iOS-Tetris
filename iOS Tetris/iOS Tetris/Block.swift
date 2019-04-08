//
//  Block.swift
//  iOS Tetris
//
//  Created by Josh Feltman on 4/8/19.
//  Copyright © 2019 Josh Feltman. All rights reserved.
//

import SpriteKit

let NumberOfColors: UInt32 = 6

enum BlockColor: Int, CustomStringConvertible {
    
    case Blue = 0, Orange = 1, Purple = 2, Red = 3, Teal = 4, Yellow = 5
    
    var spriteName: String {
        switch self {
        case .Blue:
            return "blue"
        case .Orange:
            return "orange"
        case .Purple:
            return "purple"
        case .Red:
            return "red"
        case .Teal:
            return "teal"
        case .Yellow:
            return "yellow"
        }
    }
    
    var description: String {
        return self.spriteName
    }
    
    static func random() -> BlockColor {
        return BlockColor(rawValue: Int(arc4random_uniform(NumberOfColors)))!
    }
}

class Block: Hashable, CustomStringConvertible {
    // Constants
    let color: BlockColor
    
    // Properties
    var column: Int
    var row: Int
    var sprite: SKSpriteNode?
    
    var spriteName: String {
        return color.spriteName
    }
    
    var description: String {
        return "\(color): [\(column), \(row)]"
    }
    
    // var hashValue is deprecated in Swift 4.2
    // use hash(into:) to create custom hash values
    func hash(into hasher: inout Hasher) {
        hasher.combine(column)
        hasher.combine(row)
    }

    init(column: Int, row: Int, color: BlockColor) {
        self.column = column
        self.row = row
        self.color = color
    }

}

// Used to compare Blocks, checks if the column, row, and color is the same
func ==(lhs: Block, rhs: Block) -> Bool {
    return lhs.column == rhs.column && lhs.row == rhs.row && lhs.color.rawValue == rhs.color.rawValue
}

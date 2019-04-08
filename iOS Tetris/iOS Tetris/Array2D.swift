//
//  Array2D.swift
//  iOS Tetris
//
//  Created by Josh Feltman on 4/8/19.
//  Copyright © 2019 Josh Feltman. All rights reserved.
//

// Base game board, of type T to support any data type
class Array2D<T> {
    let columns: Int
    let rows: Int
    
    // main array of type T?, to allow empty (nil) blocks
    var array: Array<T?>
    
    init(columns: Int, rows: Int) {
        self.columns = columns
        self.rows = rows
        
        self.array = Array<T?>(repeating: nil, count: rows * columns)
    }
    
    // Custom subscript for getting and setting elements of the 2D array
    subscript(column: Int, row: Int) -> T? {
        get {
            return array[(row * columns) + column]
        }
        set(newValue) {
            array[(row * columns) + column] = newValue
        }
    }
    
}

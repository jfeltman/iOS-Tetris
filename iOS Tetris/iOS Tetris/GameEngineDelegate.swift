//
//  GameEngineDelegate.swift
//  iOS Tetris
//
//  Created by Josh Feltman on 4/10/19.
//  Copyright © 2019 Josh Feltman. All rights reserved.
//

// GameEngine will notify this delegate throughout the game of certain events
// Will be used by GameViewController
protocol GameEngineDelegate {
    // Invoked when the current round of gameEngine ends
    func gameDidEnd(gameEngine: GameEngine)
    
    // Invoked after a new game has begun
    func gameDidBegin(gameEngine: GameEngine)
    
    // Invoked when the falling shape has become part of the game board
    func gameShapeDidLand(gameEngine: GameEngine)
    
    // Invoked when the falling shape has changed its location
    func gameShapeDidMove(gameEngine: GameEngine)
    
    // Invoked when the falling shape has changed its location after being dropped
    func gameShapeDidDrop(gameEngine: GameEngine)
    
    // Invoked when the game has reached a new level
    func gameDidLevelUp(gameEngine: GameEngine)
    
    // JOSH START
    // Invoked when the falling shape has been held
    func gameShapeHeld(gameEngine: GameEngine)
    // JOSH END
}

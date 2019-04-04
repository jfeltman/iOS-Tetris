# iOS-Tetris

A clone of the arcade game 'Tetris' based off of open source 'Swiftris' (https://github.com/Bloc/swiftris)

Created for Washington State Universities Mobile Application Development course.

## Core Features (From 'Swiftris')
* A random block will appear at the top of the screen and slowly fall towards the bottom of the screen
* The random block will be chosen from 7 different kinds of blocks
* Player can use tap gesture to rotate the block by 90 degrees at a time
* Player can use swipe down gesture to instantly move the block to the bottom of the screen
* Player can use a swipe left/right gesture to move the block left or right by 1 unit
* The blocks will rest on each other (using Sprite Kit’s physic engine)
* When a row has been filled with all block pieces, that row will be cleared and the remaining rows on top will be shifted down
* A scoring system will be in place and will increase in score when a row is cleared

## Features Added
* Full conversion from Swift 2 to Swift 5 and iOS 12
* Adding a user interface menu (with options to play and view leaderboard)
* Persistent score saving (on app kill and re open) using Core Data
* High Score leaderboard, which displays the 10 highest scores from the Core Data
* Increasing the difficulty based on score, e.g. when a user reaches a score of ‘400’ the blocks will start to fall faster. (Will add an option to start at higher difficulty)
* Implementing a hold feature where the player can save a block for later, on using this block the current piece falling is swapped with the held block

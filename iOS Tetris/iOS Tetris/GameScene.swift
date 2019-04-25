//
//  GameScene.swift
//  iOS Tetris
//
//  Created by Josh Feltman on 4/3/19.
//  Copyright © 2019 Josh Feltman. All rights reserved.
//

import SpriteKit
import GameplayKit

let TickLengthLevelOne = TimeInterval(1000)
let TickLengthLevelTwo = TimeInterval(1000)

var BlockSize: CGFloat = 20.0

class GameScene: SKScene {
    // JOSH START
    let screenSize = UIScreen.main.bounds
    let LayerPositionIphone8 = CGPoint(x: 6, y: -95)
    let LayerPositionIphone8Plus = CGPoint(x: 6, y: -125)
    
    let holdAreaIphone8 = CGPoint(x: 310, y: -440)
    let holdSizeIphone8 = CGSize(width: 110, height: 110)
    let holdAreaIphone8Plus = CGPoint(x: 335, y: -515)
    let holdSizeIphone8Plus = CGSize(width: 130, height: 130)
    var holdAreaPosition: CGPoint!
    var holdSize: CGSize!
    // JOSH END
    
    let gameLayer = SKNode()
    let shapeLayer = SKNode()
    
    var LayerPosition = CGPoint(x: 0, y: 0)
    var tick:(() -> ())?
    var tickLengthMillis = TickLengthLevelOne
    var lastTick: NSDate?
    
    var textureCache = Dictionary<String, SKTexture>()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoder not supported")
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
        // JOSH START
        // Set size of block/gameboard depending on screen size
        if (screenSize.height > 667.0) {
            LayerPosition = LayerPositionIphone8Plus
            holdAreaPosition = holdAreaIphone8Plus
            holdSize = holdSizeIphone8Plus
            BlockSize = 24
        } else {
            LayerPosition = LayerPositionIphone8
            holdAreaPosition = holdAreaIphone8
            holdSize = holdSizeIphone8
            BlockSize = 23
        }
        // JOSH END
        
        anchorPoint = CGPoint(x: 0, y: 1.0)
        
        // create background
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 0, y: 0)
        background.anchorPoint = CGPoint(x: 0, y: 0)
        addChild(background)
        
        // Create gameboard
        addChild(gameLayer)
        let gameBoardTexture = SKTexture(imageNamed: "gameboard")
        let gameBoard = SKSpriteNode(texture: gameBoardTexture,
                                     size: CGSize(width: BlockSize * CGFloat(NumColumns),
                                                  height: BlockSize * CGFloat(NumRows)))
        
        gameBoard.anchorPoint = CGPoint(x: 0, y: 1.0)
        gameBoard.position = LayerPosition
        
        shapeLayer.position = LayerPosition
        shapeLayer.addChild(gameBoard)
        gameLayer.addChild(shapeLayer)
        
        // JOSH - create hold node
        let holdArea = SKSpriteNode(color: UIColor.clear, size: holdSize)
        holdArea.position = holdAreaPosition
        holdArea.name = "holdArea"
        
        gameLayer.addChild(holdArea)
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        guard let lastTick = lastTick else {
            return
        }
        
        let timePassed = lastTick.timeIntervalSinceNow * -1000.0
        if timePassed > tickLengthMillis {
            self.lastTick = NSDate()
            tick?()
        }
    }
    
    func startTicking() {
        lastTick = NSDate()
    }
    
    func stopTicking() {
        lastTick = nil
    }
    
    // Returns the precise coordinate on the screen for where a block sprite belongs based on its row and column
    // Each point is anchored in the center of the block
    func pointForColumn(column: Int, row: Int) -> CGPoint {
        let x = LayerPosition.x + (CGFloat(column) * BlockSize) + (BlockSize / 2)
        let y = LayerPosition.y - ((CGFloat(row) * BlockSize) + (BlockSize / 2))
        return CGPoint(x: x, y: y)
    }
    
    // Adds the next shape to the view
    func addPreviewShapeToScene(shape: Shape, completion: @escaping () -> ()) {
        for block in shape.blocks {
            // We store the textures in the textureCache since each shape will reuse the same block sprite
            var texture = textureCache[block.spriteName]
            
            // If no texture cached, fetch one and add it to the cache
            if texture == nil {
                texture = SKTexture(imageNamed: block.spriteName)
                textureCache[block.spriteName] = texture
            }
            
            // Set the sprite
            let sprite = SKSpriteNode(texture: texture, size: CGSize(width: BlockSize, height: BlockSize))
            
            // Set the position for each block
            // For the preview, we set it at row -2 so its above the gameboard and will transition to the gameboard smoothly
            sprite.position = pointForColumn(column: block.column, row:block.row - 2)
            shapeLayer.addChild(sprite)
            block.sprite = sprite
            
            // Animation
            sprite.alpha = 0
            
            // Create the next shape animation that fades from the preview spot into the gameboard
            let moveAction = SKAction.move(to: pointForColumn(column: block.column, row: block.row), duration: TimeInterval(0.2))
            moveAction.timingMode = .easeOut
            let fadeInAction = SKAction.fadeAlpha(to: 0.7, duration: 0.4)
            fadeInAction.timingMode = .easeOut
            sprite.run(SKAction.group([moveAction, fadeInAction]))
        }
        run(SKAction.wait(forDuration: 0.4), completion: completion)
    }
    
    func movePreviewShape(shape:Shape, completion:@escaping () -> ()) {
        for block in shape.blocks {
            let sprite = block.sprite!
            let moveTo = pointForColumn(column: block.column, row:block.row)
            let moveToAction:SKAction = SKAction.move(to: moveTo, duration: 0.2)
            moveToAction.timingMode = .easeOut
            sprite.run(
                SKAction.group([moveToAction, SKAction.fadeAlpha(to: 1.0, duration: 0.2)]), completion: {})
        }
        run(SKAction.wait(forDuration: 0.2), completion: completion)
    }
    
    func redrawShape(shape:Shape, completion:@escaping () -> ()) {
        for block in shape.blocks {
            let sprite = block.sprite!
            let moveTo = pointForColumn(column: block.column, row:block.row)
            let moveToAction:SKAction = SKAction.move(to: moveTo, duration: 0.05)
            moveToAction.timingMode = .easeOut
            if block == shape.blocks.last {
                sprite.run(moveToAction, completion: completion)
            } else {
                sprite.run(moveToAction)
            }
        }
    }
    
    func animateCollapsingLines(linesToRemove: Array<Array<Block>>, fallenBlocks: Array<Array<Block>>, completion:@escaping () -> ()) {
        var longestDuration: TimeInterval = 0
        
        for (columnIdx, column) in fallenBlocks.enumerated() {
            for (blockIdx, block) in column.enumerated() {
                let newPosition = pointForColumn(column: block.column, row: block.row)
                let sprite = block.sprite!
                let delay = (TimeInterval(columnIdx) * 0.05) + (TimeInterval(blockIdx) * 0.05)
                let duration = TimeInterval(((sprite.position.y - newPosition.y) / BlockSize) * 0.1)
                let moveAction = SKAction.move(to: newPosition, duration: duration)
                moveAction.timingMode = .easeOut
                sprite.run(
                    SKAction.sequence([
                        SKAction.wait(forDuration: delay),
                        moveAction]))
                longestDuration = max(longestDuration, duration + delay)
            }
        }
        
        for rowToRemove in linesToRemove {
            for block in rowToRemove {
                // Changed from Swiftris, get rid of exlpoding animation
                let sprite = block.sprite!
                sprite.zPosition = 100
                sprite.run(SKAction.sequence([SKAction.removeFromParent()]))
            }
        }
        run(SKAction.wait(forDuration: longestDuration), completion:completion)
    }
    
    func playSound(sound: String) {
        let soundEffect = SKAction.playSoundFileNamed(sound, waitForCompletion: false)
        run(soundEffect)
    }
    
    // JOSH START
    // Move the hold shape to the hold col/row
    func moveHeldShape(shape: Shape, completion: @escaping () -> ()) {
        for block in shape.blocks {
            let sprite = block.sprite!
            let moveTo = pointForColumn(column: block.column, row:block.row)
            let moveToAction:SKAction = SKAction.move(to: moveTo, duration: 0.2)
            moveToAction.timingMode = .easeOut
            sprite.run(
                SKAction.group([moveToAction, SKAction.fadeAlpha(to: 1.0, duration: 0.2)]), completion: {})
        }
        run(SKAction.wait(forDuration: 0.2), completion: completion)
    }
    // JOSH END
    
}

//
//  Overlay.swift
//  Spaced!
//
//  Created by Jeffery Jensen on 10/25/17.
//  Copyright © 2017 Jeffery Jensen. All rights reserved.
//

import SpriteKit

class Overlay: SKScene {
    private let fuelNode = FuelLevelOvelay()
    
    init(size: CGSize, controller: GameController) {
        super.init(size: size)
        isUserInteractionEnabled = false

        // Setup the game overlays using SpriteKit.
        scaleMode = .resizeFill
        
        // The Navigation Ball.
        let navSize = CGSize(width: 200, height: 200)
        let navBallOutline = SKShapeNode(ellipseOf: navSize)
        navBallOutline.strokeColor = NSColor.white
        navBallOutline.lineWidth = 2.0
        navBallOutline.position = CGPoint(x: frame.midX, y: navSize.height / 2)
        addChild(navBallOutline)
        
        // Fuel Level
        
        let fuelSize = fuelNode.calculateAccumulatedFrame().size
        fuelNode.position = CGPoint(x: fuelSize.width / 2 + 10, y: frame.maxY - fuelSize.height)
        addChild(fuelNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateFuel(with level: Double) {
        fuelNode.updateLevel(with: level)
    }
}

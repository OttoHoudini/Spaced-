//
//  Overlay.swift
//  Spaced!
//
//  Created by Jeffery Jensen on 10/25/17.
//  Copyright © 2017 Jeffery Jensen. All rights reserved.
//

import SpriteKit
import CoreGraphics

class Overlay: SKScene {
    private let fuelNode = LevelNode()
    public let sasNode = ToggleNode()
    public let throttleNode = SKShapeNode()
    
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
        
        sasNode.position = CGPoint(x: 120 * cos(3.14 / 4), y: 120 * sin(3.14 / 4))
        navBallOutline.addChild(sasNode)
        
        throttleNode.path = CGPath(ellipseIn: CGRect.init(x: -120, y: 0, width: 15, height: 8), transform: nil)
        throttleNode.zRotation = -0.523
        throttleNode.fillColor = NSColor.white
        navBallOutline.addChild(throttleNode)
        
        // Fuel Level
        let fuelSize = fuelNode.calculateAccumulatedFrame().size
        fuelNode.position = CGPoint(x: fuelSize.width / 2 + 10, y: frame.minY + fuelSize.height + 20)
        addChild(fuelNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateFuelLevel(with percent: Double) {
        fuelNode.level = percent
    }
}

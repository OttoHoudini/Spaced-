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
    public let sasNode = ToggleNode()
 
    private let fuelNode = LevelNode()
    private let throttleNode = SKShapeNode()
    private let throttleRotation = 35.degreesToRadians

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
        
        let navBall = SK3DNode(viewportSize: navSize)
        navBall.scnScene = controller.scene
        let camera = navBall.scnScene?.rootNode.childNode(withName: "navCamera", recursively: true)
        camera?.categoryBitMask
        
        navBall.pointOfView =
        navBallOutline.addChild(navBall)
        
        // SAS Indicator
        sasNode.position = CGPoint(x: 120 * cos(3.14 / 4), y: 120 * sin(3.14 / 4))
        navBallOutline.addChild(sasNode)
        
        // Throttle Indicator
        throttleNode.path = CGPath(ellipseIn: CGRect.init(x: -(navSize.width / 2 + 20), y: 0, width: 15, height: 8), transform: nil)
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
    
    func updateThrottleLevel(with level: CGFloat) {
        throttleNode.zRotation = -(level * 2.0 * throttleRotation) + throttleRotation
    }
}

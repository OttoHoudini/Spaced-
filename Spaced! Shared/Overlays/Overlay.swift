//
//  Overlay.swift
//  Spaced!
//
//  Created by Jeffery Jensen on 10/25/17.
//  Copyright © 2017 Jeffery Jensen. All rights reserved.
//

import SpriteKit
import SceneKit
import CoreGraphics

class Overlay: SKScene {
    public let sasNode = ToggleNode()
 
    private let fuelNode = LevelNode()
    private let throttleNode = SKShapeNode()
    private let throttleRotation = 35.degreesToRadians
    private let navBall = SK3DNode(viewportSize: CGSize(width: 260, height: 260))
    
    private let navBallCam = SCNNode()
    
    init(size: CGSize, controller: GameController) {
        super.init(size: size)
        isUserInteractionEnabled = false

        // Setup the game overlays using SpriteKit.
        scaleMode = .resizeFill
        
        // The Navigation Ball.
        let navSize = CGSize(width: 200, height: 200)
        let navBallOutline = SKShapeNode(ellipseOf: navSize)
        navBallOutline.strokeColor = NSColor.white
        navBallOutline.lineWidth = 4.0
        navBallOutline.position = CGPoint(x: frame.midX, y: navSize.height / 2)
        addChild(navBallOutline)
        
        navBall.scnScene = SCNScene(named: "Art.scnassets/NavBall.scn")
        let camera = SCNCamera()
        camera.zNear = 0.5
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(0, 0, 1.25)
        navBallCam.addChildNode(cameraNode)
        navBall.scnScene?.rootNode.addChildNode(navBallCam)
        navBallOutline.addChild(navBall)
    
        let path = CGMutablePath()
        path.move(to: CGPoint(x: -60, y: 0))
        path.addLine(to: CGPoint(x: -20, y: 0))
        path.addLine(to: CGPoint(x: 0, y: -20))
        path.addLine(to: CGPoint(x: 20, y: 0))
        path.addLine(to: CGPoint(x: 60, y: 0))

        let target = SKShapeNode(path: path)
        target.strokeColor = NSColor.orange
        target.lineWidth = 4
        navBallOutline.addChild(target)
        
        let center = SKShapeNode(circleOfRadius: 4)
        center.strokeColor = NSColor.orange
        center.fillColor = NSColor.orange
        navBallOutline.addChild(center)
        
        // SAS Indicator
        sasNode.position = CGPoint(x: 120 * cos(3.14 / 4), y: 120 * sin(3.14 / 4))
        navBallOutline.addChild(sasNode)
        
        // Throttle Indicator
        let arcPath = CGMutablePath()
        arcPath.addArc(center: CGPoint(), radius: -(navSize.width / 2 + 12.5), startAngle: -throttleRotation, endAngle: throttleRotation, clockwise: false)
        let throttleBackground = SKShapeNode(path: arcPath)
        throttleBackground.strokeColor = NSColor.lightGray
        throttleBackground.alpha = 0.75
        throttleBackground.lineWidth = 10
        throttleBackground.lineCap = .round
        navBallOutline.addChild(throttleBackground)
        
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
    
    func updateNavBall(with orientation: SCNQuaternion, camOrientation: SCNQuaternion) {
        navBall.scnScene?.rootNode.childNode(withName: "navBall", recursively: true)?.orientation = orientation
        navBallCam.orientation = camOrientation
    }
}

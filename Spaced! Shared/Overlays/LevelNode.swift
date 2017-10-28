//
//  FuelLevelOvelay.swift
//  Spaced!
//
//  Created by Jeffery Jensen on 10/27/17.
//  Copyright © 2017 Jeffery Jensen. All rights reserved.
//

import SpriteKit

class LevelNode: SKNode {
    public var level = 0.0 { didSet { updateLevel(with: level) } }
    private var size = CGSize(width: 75, height: 10)
    private var outline: SKShapeNode!
    private var  fill =  SKShapeNode()


    override init() {
        super.init()
        
        outline = SKShapeNode(rectOf: size)
        outline.strokeColor = NSColor.white
        outline.lineWidth = 2.0
        addChild(outline)
        
        fill.fillColor = NSColor.green
        fill.strokeColor = NSColor.clear
        updateLevel(with: level)
        outline.addChild(fill)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateLevel(with percent: Double) {
        let fillWidth = size.width * CGFloat(percent)
        fill.path = CGPath(rect: CGRect(x: -size.width / 2, y: -size.height / 2, width: fillWidth, height: size.height), transform: nil)
    }
}

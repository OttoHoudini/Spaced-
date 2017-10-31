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
        outline.lineWidth = 0
        outline.fillColor = NSColor.green
        outline.alpha = 0.5
        addChild(outline)
        
        fill.fillColor = NSColor.green
        fill.lineWidth = 0.0
        addChild(fill)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateLevel(with percent: Double) {
        fill.path = CGPath(rect: CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width * CGFloat(percent), height: size.height), transform: nil)
    }
}

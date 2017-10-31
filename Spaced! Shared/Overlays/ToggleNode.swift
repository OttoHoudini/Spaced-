//
//  ToggleNode.swift
//  Spaced!
//
//  Created by Jeffery Jensen on 10/29/17.
//  Copyright © 2017 Jeffery Jensen. All rights reserved.
//

import SpriteKit

class ToggleNode: SKNode {
    let fillNode = SKShapeNode(circleOfRadius: 15)
    let textNode = SKLabelNode(text: "SAS")
    
    var isActive = false { didSet { updatedDisplay(active: isActive) } }
    
    override init() {
        super.init()
        
        textNode.fontSize = 12
        textNode.fontName = "Helvetica Neue Bold"
        textNode.position = CGPoint(x: 0, y: -6)
        updatedDisplay(active: false)
        
        addChild(fillNode)
        addChild(textNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updatedDisplay(active: Bool) {
        fillNode.fillColor = active ?  NSColor.white : NSColor.clear
        textNode.fontColor = active ? NSColor.lightGray : NSColor.white
    }
}

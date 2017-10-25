/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    A component that attaches to an entity. This component controls a geometry node's physics body.
*/

import SceneKit
import GameplayKit

class GeometryComponent: GKSCNNodeComponent {
    
    // MARK: -
    // MARK: Methods
        
    override init(node: SCNNode) {
        node.physicsBody?.categoryBitMask = BitmaskPart
        node.physicsBody?.collisionBitMask = BitmaskGround
        
        super.init(node: node)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func applyForce(_ direction: SCNVector3, asImpulse impulse: Bool) {
        node.physicsBody?.applyForce(direction, asImpulse: impulse)
    }
    
    func applyTorque(_ torque: SCNVector4, asImpulse impulse: Bool) {
        node.physicsBody?.applyTorque(torque, asImpulse: impulse)
    }
}

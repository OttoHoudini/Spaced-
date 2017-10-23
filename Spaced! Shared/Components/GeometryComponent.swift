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

extension SCNNode {
    func boundingBoxAnchor(_ axis: simd_float3 = simd_float3(0, 1, 0)) -> simd_float3 {
        let boundingBox = self.boundingBox
        
        let min = simd_float3(boundingBox.min)
        let max = simd_float3(boundingBox.max)
        let size = max - min // simd_float3(max.x + min.x, max.y - min.y, max.z - min.z)
        let transpose = axis * (size / 2)
        let center = (max + min) / 2 // simd_float3((max.x + min.x) / 2, (max.y + min.y) / 2, (max.z + min.z) / 2)
        
        return center + transpose
    }
}

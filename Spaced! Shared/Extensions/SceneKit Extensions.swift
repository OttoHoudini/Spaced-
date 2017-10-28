//
//  SceneKit Extensions.swift
//  Boxes
//
//  Created by Jeffery Jensen on 10/16/17.
//  Copyright © 2017 Apple. All rights reserved.
//

import SceneKit

func * (left: SCNMatrix4, right: SCNVector3) -> SCNVector3 { //multiply mat4 by vec3 as if w is 0.0
    return SCNVector3(
        left.m11 * right.x + left.m21 * right.y + left.m31 * right.z,
        left.m12 * right.x + left.m22 * right.y + left.m32 * right.z,
        left.m13 * right.x + left.m23 * right.y + left.m33 * right.z
    )
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

extension SCNPhysicsSliderJoint {
    
    public class func fixed(bodyA: SCNPhysicsBody, axisA: SCNVector3, anchorA: SCNVector3, bodyB: SCNPhysicsBody, axisB: SCNVector3, anchorB: SCNVector3) -> SCNPhysicsSliderJoint {
        let joint = SCNPhysicsSliderJoint(bodyA: bodyA, axisA: axisA, anchorA: anchorA, bodyB: bodyB, axisB: axisB, anchorB: anchorB)
        
        joint.maximumLinearLimit = 0.0
        joint.minimumLinearLimit = 0.0
        joint.maximumAngularLimit = 0.0
        joint.minimumAngularLimit = 0.0
        joint.motorMaximumTorque = 0
        joint.motorMaximumForce = 0
        
        return joint
    }
}

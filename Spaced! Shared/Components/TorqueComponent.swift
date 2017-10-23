//
//  ReactionWheelComponent.swift
//  Boxes
//
//  Created by Jeffery Jensen on 10/14/17.
//  Copyright © 2017 Apple. All rights reserved.
//

import GameplayKit

class TorqueComponent: GKComponent {
    // MARK: Properties
    
    let magnitude: CGFloat
    let angularDamping: CGFloat
    var direction = simd_float3()
    
    var geometryComponent: GeometryComponent? {
        return entity?.component(ofType: GeometryComponent.self)
    }

    // MARK: -
    // MARK: Methods
    
    init(magnitude: CGFloat, angularDamping: CGFloat) {
        self.magnitude = magnitude
        self.angularDamping = angularDamping
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setAngularDamping(active: Bool) {
        geometryComponent?.node.physicsBody?.angularDamping = active ? angularDamping : 0.0
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        guard direction != simd_float3(), let geometryNode = geometryComponent else { return }
        
        let torqueAxis = geometryNode.node.presentation.worldTransform * SCNVector3(direction)
        let torque = SCNVector4(torqueAxis.x, torqueAxis.y, torqueAxis.z, magnitude)
        geometryNode.applyTorque(torque, asImpulse: false)
    }
}

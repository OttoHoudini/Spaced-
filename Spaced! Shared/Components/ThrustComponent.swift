//
//  ThrustComponent.swift
//  Boxes
//
//  Created by Jeffery Jensen on 10/7/17.
//  Copyright © 2017 Apple. All rights reserved.
//

import GameplayKit

class ThrustComponent: RocketComponent {
    
    // MARK: Properties
    
    /// The maximum thrust.
    let maxThrust: Double
    
    /// The fuel consumption rate.
    let fuelConsumptionRate: Double
    
    /// The direction the thrust is applied.
    let directionVector = simd_double3(0, 0, 1)
    
    /// A convenience property for the entity's geometry component.
    var geometryComponent: GeometryComponent? {
        return entity?.component(ofType: GeometryComponent.self)
    }
    
    // MARK: -
    // MARK: Methods
    
    init(rocketEntity: RocketEntity, maxThrust: Double, fuelconsumptionRate: Double) {
        self.maxThrust = maxThrust
        self.fuelConsumptionRate = fuelconsumptionRate
        
        super.init()
        
        self.rocketEntity = rocketEntity
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        guard let rocket = rocketEntity, rocket.throttleComponent.level > 0.0,
            rocket.remainingFuel() > 0 else {
            return
        }
        
        let vector = geometryComponent!.node.presentation.worldTransform * SCNVector3(directionVector)

        let thrustVector = simd_double3(vector) * (rocket.throttleComponent.level * maxThrust)
        geometryComponent?.applyForce(SCNVector3(thrustVector), asImpulse: false)
    }
}

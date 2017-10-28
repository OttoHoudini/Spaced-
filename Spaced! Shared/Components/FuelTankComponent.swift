//
//  FuelComponent.swift
//  Boxes
//
//  Created by Jeffery Jensen on 10/8/17.
//  Copyright © 2017 Apple. All rights reserved.
//

import GameplayKit

class FuelTankComponent: RocketComponent {
    
    //MARK: Properties
    
    /// The max amount of fuel the tank can hold
    let maxFuelAmount: Double
    
    /// The remaining fuel in the tank
    var remainingFuel: Double
    
    //MARK: -
    //MARK: Methods
    
    init(rocket: RocketEntity? = nil, maxAmount: Double) {
        self.maxFuelAmount = maxAmount
        self.remainingFuel = maxAmount
        
        super.init()

        self.rocketEntity = rocket
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        guard remainingFuel > 0.0, let rocket = rocketEntity, rocket.throttleComponent.level > 0 else { return }
        
        let consumedFuel = rocket.throttleComponent.level * rocket.fuelConsumptionRate() * seconds
        let newRemainingFuel = remainingFuel - consumedFuel
        
        remainingFuel = newRemainingFuel < 0 ? 0.0 : newRemainingFuel
    }
}

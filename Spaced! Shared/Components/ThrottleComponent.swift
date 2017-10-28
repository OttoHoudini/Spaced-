//
//  ThrottleComponent.swift
//  Boxes
//
//  Created by Jeffery Jensen on 10/12/17.
//  Copyright © 2017 Apple. All rights reserved.
//

import GameplayKit

class ThrottleComponent: GKComponent {
    
    /// The rate that the throttle level can be adjusted
    private let changeRate = 0.5
    
    /// The throttles level amount.  It is limited from 0 to 1.
    var level = 0.0

    /// The different states the throttle can be in.
    enum State {
        case off
        case up
        case down
        case hold
    }
    
    /// The current state the throttle is in.
    var state = ThrottleComponent.State.off {
        didSet { if state == .off { level = 0.0 } }
    }
    
    // MARK: -
    // MARK: Methods
    
    override func update(deltaTime seconds: TimeInterval) {
        guard state  == .up || state == .down else { return }
        
        let delta = state == .up ? changeRate : -changeRate
        let newLevel = level + delta * seconds
        
        level = (newLevel...newLevel).clamped(to: 0...1).lowerBound
        print("Thottle: \(level)")
    }
}

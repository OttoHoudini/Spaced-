//
//  Rocket.swift
//  Boxes
//
//  Created by Jeffery Jensen on 10/9/17.
//  Copyright © 2017 Apple. All rights reserved.
//

import GameplayKit

class RocketEntity: GKEntity {
    
    //MARK: Properties
    
    var partEntities = [GKEntity]() {
        didSet {
            for partEntity in partEntities {
                torqueComponentSystem.addComponent(foundIn: partEntity)
                particleComponentSystem.addComponent(foundIn: partEntity)
                thrustComponentSystem.addComponent(foundIn: partEntity)
                fuelTankComponentSystem.addComponent(foundIn: partEntity)
            }
        }
    }
    
    var throttleComponent: ThrottleComponent {
        return component(ofType: ThrottleComponent.self)!
    }
    
    var torqueDirection = simd_float3() {
        didSet { let _ = torqueComponentSystem.components.map() {
            $0.direction = torqueDirection }
            print("DidSet Torque Direction: \(torqueDirection)")
        }
    }
    
    var isSASActive = false {
        didSet { let _ = torqueComponentSystem.components.map() {
            $0.setAngularDamping(active: isSASActive)
            print("DidSet SAS: \(isSASActive)")
            }
        }
    }
    
    let torqueComponentSystem = GKComponentSystem<TorqueComponent>(componentClass: TorqueComponent.self)
    let thrustComponentSystem = GKComponentSystem<ThrustComponent>(componentClass: ThrustComponent.self)
    let fuelTankComponentSystem = GKComponentSystem<FuelTankComponent>(componentClass: FuelTankComponent.self)
    let particleComponentSystem = GKComponentSystem<ParticleComponent>(componentClass: ParticleComponent.self)

    //MARK: -
    //MARK Methods
    
    override init() {
        super.init()
        
        self.addComponent(ThrottleComponent())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupJoints(_ scene: SCNScene) {
        var lowerNode: SCNNode?
        let yAxis = simd_float3(0, 1, 0)

        for entity in partEntities {
            guard let nodeA = entity.component(ofType: GeometryComponent.self)?.node,
                let physicsBodyA = nodeA.physicsBody else { return }

            var bodyBTopAnchor = simd_float3()

            if let nodeB = lowerNode {
                guard  let physicsBodyB = nodeB.physicsBody else { return }
                
                let bodyABottonAnchor = nodeA.boundingBoxAnchor(-1 * yAxis)
                bodyBTopAnchor = nodeB.boundingBoxAnchor()
                
                let joint = SCNPhysicsSliderJoint.fixed(
                    bodyA: physicsBodyA, axisA: SCNVector3(yAxis), anchorA: SCNVector3(bodyABottonAnchor),
                    bodyB: physicsBodyB, axisB: SCNVector3(yAxis), anchorB: SCNVector3(bodyBTopAnchor))
                
                scene.physicsWorld.addBehavior(joint)
                
                bodyBTopAnchor = nodeB.simdConvertPosition(bodyBTopAnchor, to: scene.rootNode)
            }
            
            nodeA.simdPosition = bodyBTopAnchor - nodeA.boundingBoxAnchor(-1 * yAxis)
            
            lowerNode = nodeA
        }
    }
    
    func setThrottleState(_ state: ThrottleComponent.State) {
        print("Set Thottle state: \(state)")
        
        self.throttleComponent.state = state
    }
    
    func fuelConsumptionRate() -> Double {
        return thrustComponentSystem.components.map{$0.fuelConsumptionRate}.reduce(0.0, +)
    }
    
    func hasFuel() -> Bool {
        return fuelTankComponentSystem.components.map {$0.remainingFuel}.reduce(0.0, +) > 0 ? true : false
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        throttleComponent.update(deltaTime: seconds)
        torqueComponentSystem.update(deltaTime: seconds)
        torqueComponentSystem.update(deltaTime: seconds)
        thrustComponentSystem.update(deltaTime: seconds)
        fuelTankComponentSystem.update(deltaTime: seconds)
        particleComponentSystem.update(deltaTime: seconds)
    }
}

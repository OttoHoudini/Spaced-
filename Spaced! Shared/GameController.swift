//
//  GameController.swift
//  Spaced! Shared
//
//  Created by Jeffery Jensen on 9/14/17.
//  Copyright © 2017 Jeffery Jensen. All rights reserved.
//

import SceneKit
import GameplayKit

#if os(watchOS)
    import WatchKit
#endif

#if os(macOS)
    typealias SCNColor = NSColor
#else
    typealias SCNColor = UIColor
#endif

let BitmaskRocketCamera     = Int(1 << 2)
let BitmaskNavigationCamera = Int(1 << 3)
let BitmaskMapCamera        = Int(1 << 4)
let BitmaskGround           = Int(1 << 5)
let BitmaskPart             = Int(1 << 6)

class GameController: NSObject, SCNSceneRendererDelegate {

    // Global settings
    static let DefaultCameraTransitionDuration = 1.0
    static let CameraOrientationSensitivity: Float = 0.025

    // Overlays
    private var overlay: Overlay?

    let scene: SCNScene
    let sceneRenderer: SCNSceneRenderer
    
    var currentRocket = RocketEntity()
    
    
    private var controlNode: SCNNode?
    private var currentSphereOfInfluence: SCNNode!

    private var cameraNode = SCNNode()
    private var activeCamera: SCNNode?
    private var lastActiveCamera: SCNNode?
    private var lastActiveCameraFrontDirection = simd_float3.zero
    private let spaceCamera = SCNNode()
    private let atmosphereCamera = SCNNode()
    
    private let navNode = SCNNode()
     
    /// Keeps track of the time for use in the update method.
    var previousUpdateTime: TimeInterval = 0
    
    init(sceneRenderer renderer: SCNView) {
        renderer.rendersContinuously = true
        sceneRenderer = renderer
        sceneRenderer.showsStatistics = true

        scene = SCNScene(named: "Art.scnassets/ship.scn")!
        
        super.init()
        
        sceneRenderer.delegate = self
        
        setUpEntities()
        setupCamera()
        
        // setup overlay
        overlay = Overlay(size: renderer.bounds.size, controller: self)
        renderer.overlaySKScene = overlay
        
        sceneRenderer.scene = scene
        
        setupNavBallNode()
    }
    
    func setupNavBallNode() {
        weak var weakSelf = self

        let characterPositionContraint = SCNTransformConstraint.positionConstraint(
            inWorldSpace: true, with: { (_ node: SCNNode, _ position: SCNVector3) -> SCNVector3 in
                guard let strongSelf = weakSelf else { return position }
                
                guard let worldPosition = strongSelf.controlNode?.presentation.worldPosition else { return position }
                return worldPosition
        })
        
        let lookAtConstraint = SCNLookAtConstraint(target: currentSphereOfInfluence)
        lookAtConstraint.isGimbalLockEnabled = true
        
        navNode.constraints = [characterPositionContraint, lookAtConstraint]
        scene.rootNode.addChildNode(navNode)
    }
    
    func setUpEntities() {
        // Create entities with components using the factory method.
        
        currentSphereOfInfluence = scene.rootNode.childNode(withName: "sphere", recursively: true)!
        currentSphereOfInfluence.physicsBody?.categoryBitMask = BitmaskGround
        currentSphereOfInfluence.physicsBody?.collisionBitMask = BitmaskPart
        
        let ship = makeBoxEntity(forNodeWithName: "ship", wantsTorqueComponent: true, wantsThrustComponent: true, wantsFuelComponent: true)
        
        controlNode = ship.component(ofType: GeometryComponent.self)?.node
        currentRocket.partEntities = [ship]
        currentRocket.setupJoints(scene)
    }
    
    // MARK: - Camera Controls
    
    var cameraDirection = vector_float2.zero {
        didSet {
            let l = simd_length(cameraDirection)
            if l > 1.0 {
                cameraDirection *= 1 / l
            }
        }
    }
    
    func setupCamera() {
        setupAtmosphereCamera(atmosphereCamera)
        setupSpaceCamera(spaceCamera)
        
        self.cameraNode.camera = SCNCamera()
        self.cameraNode.name = "mainCamera"
        self.cameraNode.camera!.zNear = 1
        self.cameraNode.camera!.zFar = 5000

        self.scene.rootNode.addChildNode(cameraNode)
        
        setActiveCamera("atmosphereCam", animationDuration: 0.0)
    }

    func setupSpaceCamera(_ node: SCNNode) {
        weak var weakSelf = self
        
        // Setup lookAtTargets
        let characterPositionContraint = SCNTransformConstraint.positionConstraint(
            inWorldSpace: true, with: { (_ node: SCNNode, _ position: SCNVector3) -> SCNVector3 in
                guard let strongSelf = weakSelf else { return position }
                
                guard let worldPosition = strongSelf.controlNode?.presentation.worldPosition else { return position }
                return worldPosition
        })
        
        let spaceLookAtTarget = SCNNode()
        spaceLookAtTarget.constraints = [characterPositionContraint]
        
        // Setup Orientation nodes
        let spaceOrientationConstraint = SCNTransformConstraint(inWorldSpace: true) { (_ node: SCNNode, _ transform: SCNMatrix4) -> SCNMatrix4 in
            if self.cameraDirection.allZero() {
                return transform
            }
            
            let transformNode = SCNNode()
            transformNode.transform = transform
            
            let q = simd_mul(
                simd_quaternion(GameController.CameraOrientationSensitivity * self.cameraDirection.x, spaceLookAtTarget.presentation.simdWorldUp),
                simd_quaternion(GameController.CameraOrientationSensitivity * self.cameraDirection.y, transformNode.simdWorldRight)
            )
            
            transformNode.simdRotate(by: q, aroundTarget: spaceLookAtTarget.presentation.simdPosition)
            return transformNode.transform
        }
        
        let lookAtTarget = SCNLookAtConstraint(target: spaceLookAtTarget)
        
        spaceLookAtTarget.addChildNode(node)
        node.name = "spaceCam"
        node.simdPosition = simd_float3(0, -35, 0)
        node.constraints = [spaceOrientationConstraint, lookAtTarget]
        
        self.scene.rootNode.addChildNode(spaceLookAtTarget)
    }

    func setupAtmosphereCamera(_ node: SCNNode) {
        weak var weakSelf = self
        
        // Setup lookAtTargets
        let characterPositionContraint = SCNTransformConstraint.positionConstraint(
            inWorldSpace: true, with: { (_ node: SCNNode, _ position: SCNVector3) -> SCNVector3 in
                guard let strongSelf = weakSelf else { return position }
                
                guard let worldPosition = strongSelf.controlNode?.presentation.worldPosition else { return position }
                return worldPosition
        })
        
        let atmosphereLookAtTarget = SCNNode()
        atmosphereLookAtTarget.constraints = [characterPositionContraint, SCNLookAtConstraint(target: self.currentSphereOfInfluence)]
        
        // Setup Orientation nodes
        let atmosphereOrientationConstraint = SCNTransformConstraint(inWorldSpace: true) { (_ node: SCNNode, _ transform: SCNMatrix4) -> SCNMatrix4 in
            if self.cameraDirection.allZero() {
                return transform
            }
            
            let transformNode = SCNNode()
            transformNode.transform = transform
            
            let q = simd_mul(
                simd_quaternion(GameController.CameraOrientationSensitivity * -self.cameraDirection.x, atmosphereLookAtTarget.presentation.simdWorldFront),
                simd_quaternion(GameController.CameraOrientationSensitivity * self.cameraDirection.y, transformNode.simdWorldRight)
            )
            
            transformNode.simdRotate(by: q, aroundTarget: atmosphereLookAtTarget.presentation.simdPosition)
            return transformNode.transform
        }
        
        let lookAtTarget = SCNLookAtConstraint(target: atmosphereLookAtTarget)

        atmosphereLookAtTarget.addChildNode(node)
        node.name = "atmosphereCam"
        node.simdPosition = simd_float3(0, -35, 0)
        node.constraints = [atmosphereOrientationConstraint, lookAtTarget]
        self.scene.rootNode.addChildNode(atmosphereLookAtTarget)
    }
    
    func setActiveCamera(_ cameraName: String, animationDuration duration: CFTimeInterval) {
        guard let camera = scene.rootNode.childNode(withName: cameraName, recursively: true) else { return }
        if self.activeCamera == camera {
            return
        }
        
        self.activeCamera = camera
        
        // save old transform in world space
        let oldTransform: SCNMatrix4 = cameraNode.presentation.worldTransform
        
        // re-parent
        camera.addChildNode(cameraNode)
        
        // compute the old transform relative to our new parent node (yeah this is the complex part)
        let parentTransform = camera.presentation.worldTransform
        let parentInv = SCNMatrix4Invert(parentTransform)
        
        // with this new transform our position is unchanged in workd space (i.e we did re-parent but didn't move).
        cameraNode.transform = SCNMatrix4Mult(oldTransform, parentInv)
        
        // now animate the transform to identity to smoothly move to the new desired position
        SCNTransaction.begin()
        SCNTransaction.animationDuration = duration
        SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        cameraNode.transform = SCNMatrix4Identity
        
        if let cameraTemplate = camera.camera {
            cameraNode.camera!.fieldOfView = cameraTemplate.fieldOfView
            cameraNode.camera!.wantsDepthOfField = cameraTemplate.wantsDepthOfField
            cameraNode.camera!.sensorHeight = cameraTemplate.sensorHeight
            cameraNode.camera!.fStop = cameraTemplate.fStop
            cameraNode.camera!.focusDistance = cameraTemplate.focusDistance
            cameraNode.camera!.bloomIntensity = cameraTemplate.bloomIntensity
            cameraNode.camera!.bloomThreshold = cameraTemplate.bloomThreshold
            cameraNode.camera!.bloomBlurRadius = cameraTemplate.bloomBlurRadius
            cameraNode.camera!.wantsHDR = cameraTemplate.wantsHDR
            cameraNode.camera!.wantsExposureAdaptation = cameraTemplate.wantsExposureAdaptation
            cameraNode.camera!.vignettingPower = cameraTemplate.vignettingPower
            cameraNode.camera!.vignettingIntensity = cameraTemplate.vignettingIntensity
        }
        SCNTransaction.commit()
    }

    func highlight(node: SCNNode) {
        // get its material
        let material =  node.geometry!.firstMaterial!
        
        // highlight it
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.5
        
        // on completion - unhighlight
        SCNTransaction.completionBlock = {
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            
            material.emission.contents = NSColor.black
            
            SCNTransaction.commit()
        }
        
        material.emission.contents = NSColor.red
        
        SCNTransaction.commit()
    }
    
    /**
     Updates every frame, and keeps components in the particle component
     system up to date.
     */
    func renderer(_: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        // Calculate the time change since the previous update.
        let timeSincePreviousUpdate = time - previousUpdateTime
        
        currentRocket.update(deltaTime: timeSincePreviousUpdate)
        
        // Update overlay
        let overlay = sceneRenderer.overlaySKScene as! Overlay
        overlay.updateFuelLevel(with: currentRocket.remainingFuel() / currentRocket.initialFuel())
        overlay.updateThrottleLevel(with: CGFloat(currentRocket.throttleComponent.level))
        overlay.updateNavBall(with: navNode.presentation.orientation, camOrientation: controlNode!.presentation.orientation)
        overlay.updateSpeedOdometer(with: (controlNode?.physicsBody!.velocity)!)
        
        let altitude = (controlNode?.presentation.position.length().rounded())! - 1000
        overlay.updateAltimeter(with: altitude)
        
        let camera = altitude > 500 ? "spaceCam" : "atmosphereCam"
        setActiveCamera(camera, animationDuration: 0.5)

        
        // Update the previous update time to keep future calculations accurate.
        previousUpdateTime = time
    }
    
    func makeBoxEntity(forNodeWithName name: String, wantsTorqueComponent: Bool = false, wantsThrustComponent: Bool = false, wantsFuelComponent: Bool = false, withParticleComponentNamed particleComponentName: String? = nil) -> GKEntity {
        
        // Create the box entity and grab its node from the scene.
        let box = GKEntity()
        guard let boxNode = scene.rootNode.childNode(withName: name, recursively: false) else {
            fatalError("Making box with name \(name) failed because the GameScene scene file contains no nodes with that name.")
        }
        
        // Create and attach a geometry component to the box.
        let geometryComponent = GeometryComponent(node: boxNode)
        box.addComponent(geometryComponent)
        
        // If requested, create and attach a particle component.
        if let particleComponentName = particleComponentName {
            let particleComponent = ParticleComponent(particleName: particleComponentName)
            box.addComponent(particleComponent)
        }
        
        // If requested, create and attach a thrust component.
        if wantsThrustComponent {
            let thrustComponent = ThrustComponent(rocketEntity: currentRocket, maxThrust: 50, fuelconsumptionRate: 1.0)
            box.addComponent(thrustComponent)
        }
        
        if wantsFuelComponent {
            let fuelComponent = FuelTankComponent(rocket: currentRocket, maxAmount: 50)
            box.addComponent(fuelComponent)
        }
        
        if wantsTorqueComponent {
            let torqueComponent = TorqueComponent(magnitude: 40, angularDamping: 0.8)
            box.addComponent(torqueComponent)
        }
        
        return box
    }
}

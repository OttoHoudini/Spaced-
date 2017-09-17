//
//  GameController.swift
//  Spaced! Shared
//
//  Created by Jeffery Jensen on 9/14/17.
//  Copyright © 2017 Jeffery Jensen. All rights reserved.
//

import SceneKit

#if os(watchOS)
    import WatchKit
#endif

#if os(macOS)
    typealias SCNColor = NSColor
#else
    typealias SCNColor = UIColor
#endif

class GameController: NSObject, SCNSceneRendererDelegate {

    // Global settings
    static let DefaultCameraTransitionDuration = 1.0
    static let CameraOrientationSensitivity: Float = 0.025

    
    let scene: SCNScene
    let sceneRenderer: SCNSceneRenderer
    
    private var activeShip: SCNNode?
    private var currentSphereOfInfluence: SCNNode!

    private var cameraNode = SCNNode()
    private var activeCamera: SCNNode?
    private var lastActiveCamera: SCNNode?
    private var lastActiveCameraFrontDirection = simd_float3.zero
    private let spaceCamera = SCNNode()
    private let atmosphereCamera = SCNNode()

    init(sceneRenderer renderer: SCNSceneRenderer) {
        sceneRenderer = renderer
        scene = SCNScene(named: "Art.scnassets/ship.scn")!
        
        super.init()
        
        activeShip = scene.rootNode.childNode(withName: "ship", recursively: true)
        currentSphereOfInfluence = scene.rootNode.childNode(withName: "sphere", recursively: true)
        
        setupCamera()
        
        sceneRenderer.delegate = self
        sceneRenderer.scene = scene
    }
    
    func launchRocket() {
        activeShip?.physicsBody?.applyForce(SCNVector3(0, 0, 20), asImpulse: true)
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
        
        self.cameraNode.camera = SCNCamera()
        self.cameraNode.name = "mainCamera"
        self.cameraNode.camera!.zNear = 1
        self.cameraNode.camera!.zFar = 500

        self.scene.rootNode.addChildNode(cameraNode)
        
        setActiveCamera("atmosphereCam", animationDuration: 0.0)
    }

    func setupSpaceCamera(_ node: SCNNode) {
        weak var weakSelf = self
        
        // Setup lookAtTargets
        let characterPositionContraint = SCNTransformConstraint.positionConstraint(
            inWorldSpace: true, with: { (_ node: SCNNode, _ position: SCNVector3) -> SCNVector3 in
                guard let strongSelf = weakSelf else { return position }
                
                guard let worldPosition = strongSelf.activeShip?.presentation.worldPosition else { return position }
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
        node.simdPosition = simd_float3(15, 0, 0)
        node.constraints = [spaceOrientationConstraint, lookAtTarget]
        
        self.scene.rootNode.addChildNode(spaceLookAtTarget)
    }

    func setupAtmosphereCamera(_ node: SCNNode) {
        weak var weakSelf = self
        
        // Setup lookAtTargets
        let characterPositionContraint = SCNTransformConstraint.positionConstraint(
            inWorldSpace: true, with: { (_ node: SCNNode, _ position: SCNVector3) -> SCNVector3 in
                guard let strongSelf = weakSelf else { return position }
                
                guard let worldPosition = strongSelf.activeShip?.presentation.worldPosition else { return position }
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
        node.simdPosition = simd_float3(15, 0, 0)
        node.constraints = [atmosphereOrientationConstraint, lookAtTarget]
        node.simdEulerAngles = simd_float3(1.57, 0, 1.57)
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

    func highlightNodes(atPoint point: CGPoint) {
        let hitResults = self.sceneRenderer.hitTest(point, options: [:])
        for result in hitResults {
            // get its material
            guard let material = result.node.geometry?.firstMaterial else {
                return
            }
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            
            // on completion - unhighlight
            SCNTransaction.completionBlock = {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                
                material.emission.contents = SCNColor.black
                
                SCNTransaction.commit()
            }
            
            material.emission.contents = SCNColor.red
            
            SCNTransaction.commit()
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        // Called before each frame is rendered
        
//        if let ship = activeShip {
//            let newCamera = length(ship.presentation.simdWorldPosition) >= 150 ? "spaceCam" : "atmosphereCam"
//            setActiveCamera(newCamera, animationDuration: GameController.DefaultCameraTransitionDuration)
//        }
    }

}

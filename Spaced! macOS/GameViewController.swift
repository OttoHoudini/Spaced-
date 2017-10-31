//
//  GameViewController.swift
//  Spaced! macOS
//
//  Created by Jeffery Jensen on 9/14/17.
//  Copyright © 2017 Jeffery Jensen. All rights reserved.
//

//import Cocoa
import SceneKit
import SpriteKit

private enum TorqueDirection : UInt16 {
    case yawLeft = 0
    case yawRight = 2
    case pitchUp = 13
    case pitchDown = 1
    case rollLeft = 12
    case rollRight = 14
    
    var vector : float3 {
        switch self {
        case .yawLeft: return float3(0, 1, 0)
        case .yawRight: return float3(0, -1, 0)
        case .pitchUp: return float3(-1, 0, 0)
        case .pitchDown: return float3(1, 0, 0)
        case .rollLeft: return float3(0, 0, -1)
        case .rollRight: return float3(0, 0, 1)
        }
    }
}

class GameViewController: NSViewController {
    
    var gameView: GameViewMacOS {
        guard let gameView = view as? GameViewMacOS else {
            fatalError("Expected \(GameViewMacOS.self) from Main.storyboard.")
        }
        return gameView
    }
    
    var gameController: GameController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.gameController = GameController(sceneRenderer: gameView)
        
        // Link view and controller
        gameView.viewController = self
               
        
        // Add a click gesture recognizer
        let clickGesture = NSClickGestureRecognizer(target: self, action: #selector(handleClick(_:)))
        var gestureRecognizers = gameView.gestureRecognizers
        gestureRecognizers.insert(clickGesture, at: 0)
        self.gameView.gestureRecognizers = gestureRecognizers
    }
    
    @objc
    func handleClick(_ gestureRecognizer: NSGestureRecognizer) {
    }
    
    override func flagsChanged(with event: NSEvent) {
        if event.modifierFlags.contains(.shift) {
            gameController.currentRocket.setThrottleState(.up)
            
        } else if event.modifierFlags.contains(.control) {
            gameController.currentRocket.setThrottleState(.down)
            
        } else {
            gameController.currentRocket.setThrottleState(.hold)
        }
    }
    
    override func keyDown(with event: NSEvent) {
        if event.characters == "z", !event.isARepeat {
            gameController.currentRocket.setThrottleState(.off)
        }
        
        if let direction = TorqueDirection(rawValue: event.keyCode), !event.isARepeat {
            gameController.currentRocket.torqueDirection += direction.vector
        }
        
        if let characters = event.characters, characters.contains("t"), !event.isARepeat {
            gameController.currentRocket.isSASActive = !gameController.currentRocket.isSASActive
            (gameController.sceneRenderer.overlaySKScene as! Overlay).sasNode.isActive = gameController.currentRocket.isSASActive
        }
        
        var cameraDirection = self.gameController!.cameraDirection
        var updateCamera = false
        
        switch event.keyCode {
        case 126:
            // Camera Up
            if !event.isARepeat {
                cameraDirection.y = -1
                updateCamera = true
            }
        case 125:
            // Camera Down
            if !event.isARepeat {
                cameraDirection.y = 1
                updateCamera = true
            }
        case 123:
            // Camera Left
            if !event.isARepeat {
                cameraDirection.x = -1
                updateCamera = true
            }
        case 124:
            // Camera Right
            if !event.isARepeat {
                cameraDirection.x = 1
                updateCamera = true
            }
        default:
            break
        }
        
        if updateCamera {
            self.gameController?.cameraDirection = cameraDirection.allZero() ? cameraDirection: simd_normalize(cameraDirection)
        }
    }
    
    override func keyUp(with event: NSEvent) {
        if let direction = TorqueDirection(rawValue: event.keyCode), !event.isARepeat {
            gameController.currentRocket.torqueDirection -= direction.vector
        }
        
        var cameraDirection = gameController!.cameraDirection
        var updateCamera = false
        
        switch event.keyCode {
        case 126:
            // Camera Up
            if !event.isARepeat && cameraDirection.y < 0 {
                cameraDirection.y = 0
                updateCamera = true
            }
        case 125:
            // Camera Down
            if !event.isARepeat && cameraDirection.y > 0 {
                cameraDirection.y = 0
                updateCamera = true
            }
        case 123:
            // Camera Left
            if !event.isARepeat && cameraDirection.x < 0 {
                cameraDirection.x = 0
                updateCamera = true
            }
        case 124:
            // Camera Right
            if !event.isARepeat && cameraDirection.x > 0 {
                cameraDirection.x = 0
                updateCamera = true
            }
        default:
            break
        }
        
        if updateCamera {
            self.gameController?.cameraDirection = cameraDirection.allZero() ? cameraDirection: simd_normalize(cameraDirection)
        }
    }
}

class GameViewMacOS: SCNView {
    weak var viewController: GameViewController?
    
    override func keyDown(with theEvent: NSEvent) {
        viewController?.keyDown(with: theEvent)
    }
    
    override func keyUp(with theEvent: NSEvent) {
        viewController?.keyUp(with: theEvent)
    }
//    override func viewDidMoveToWindow() {
//        //disable retina
//        layer?.contentsScale = 1.0
//    }
}

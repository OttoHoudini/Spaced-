//
//  GameViewController.swift
//  Spaced! macOS
//
//  Created by Jeffery Jensen on 9/14/17.
//  Copyright © 2017 Jeffery Jensen. All rights reserved.
//

import Cocoa
import SceneKit

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
        
        // Show statistics such as fps and timing information
        self.gameView.showsStatistics = true
        
        // Add a click gesture recognizer
        let clickGesture = NSClickGestureRecognizer(target: self, action: #selector(handleClick(_:)))
        var gestureRecognizers = gameView.gestureRecognizers
        gestureRecognizers.insert(clickGesture, at: 0)
        self.gameView.gestureRecognizers = gestureRecognizers
    }
    
    @objc
    func handleClick(_ gestureRecognizer: NSGestureRecognizer) {
        gameController.launchRocket()
    }
    
    func keyDown(_ view: NSView, event theEvent: NSEvent) -> Bool {
        var cameraDirection = self.gameController!.cameraDirection
        
        var updateCamera = false
        let updateCharacter = false
        
        switch theEvent.keyCode {
        case 13:
            // Up
            if !theEvent.isARepeat {
                
            }
        case 1:
            // Down
            if !theEvent.isARepeat {
                
            }
        case 0:
            // Left
            if !theEvent.isARepeat {
                
            }
        case 2:
            // Right
            if !theEvent.isARepeat {
                
            }
        case 126:
            // Camera Up
            if !theEvent.isARepeat {
                cameraDirection.y = -1
                updateCamera = true
            }
        case 125:
            // Camera Down
            if !theEvent.isARepeat {
                cameraDirection.y = 1
                updateCamera = true
            }
        case 123:
            // Camera Left
            if !theEvent.isARepeat {
                cameraDirection.x = -1
                updateCamera = true
            }
        case 124:
            // Camera Right
            if !theEvent.isARepeat {
                cameraDirection.x = 1
                updateCamera = true
            }
        case 49:
            // Space
            if !theEvent.isARepeat {
            }
            return true
        case 8:
            // c
            if !theEvent.isARepeat {
            }
            return true
        default:
            return false
        }
        
        if updateCharacter {
            
        }
        
        if updateCamera {
            self.gameController?.cameraDirection = cameraDirection.allZero() ? cameraDirection: simd_normalize(cameraDirection)
        }
        
        return true
    }

    func keyUp(_ view: NSView, event theEvent: NSEvent) -> Bool {
        var cameraDirection = gameController!.cameraDirection
        
        var updateCamera = false
        let updateCharacter = false
        
        switch theEvent.keyCode {
        case 36:
            if !theEvent.isARepeat {
                //                gameController!.resetPlayerPosition()
            }
            return true
        case 13:
            // Up
            return false
            
        case 1:
            // Down
            return false
            
        case 0:
            // Left
            return false
            
        case 2:
            // Right
            return false
            
        case 126:
            // Camera Up
            if !theEvent.isARepeat && cameraDirection.y < 0 {
                cameraDirection.y = 0
                updateCamera = true
            }
        case 125:
            // Camera Down
            if !theEvent.isARepeat && cameraDirection.y > 0 {
                cameraDirection.y = 0
                updateCamera = true
            }
        case 123:
            // Camera Left
            if !theEvent.isARepeat && cameraDirection.x < 0 {
                cameraDirection.x = 0
                updateCamera = true
            }
        case 124:
            // Camera Right
            if !theEvent.isARepeat && cameraDirection.x > 0 {
                cameraDirection.x = 0
                updateCamera = true
            }
            
        case 49:
            // Space
            if !theEvent.isARepeat {
            }
            return true
        default:
            break
        }
        // swiftlint:enable function_body_length
        
        if updateCharacter {
            
        }
        
        if updateCamera {
            self.gameController?.cameraDirection = cameraDirection.allZero() ? cameraDirection: simd_normalize(cameraDirection)
            return true
        }
        
        return false
    }

}

class GameViewMacOS: SCNView {
    weak var viewController: GameViewController?
    
    // MARK: - EventHandler
    
    override func keyDown(with theEvent: NSEvent) {
        if viewController?.keyDown(self, event: theEvent) == false {
            super.keyDown(with: theEvent)
        }
    }
    
    override func keyUp(with theEvent: NSEvent) {
        if viewController?.keyUp(self, event: theEvent) == false {
            super.keyUp(with: theEvent)
        }
    }
    
//    override func viewDidMoveToWindow() {
//        //disable retina
//        layer?.contentsScale = 1.0
//    }
}

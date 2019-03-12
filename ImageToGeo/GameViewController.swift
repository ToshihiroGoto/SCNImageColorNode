//
//  GameViewController.swift
//  ImageToGeo
//
//  Created by Toshihiro Goto on 2019/03/11.
//  Copyright © 2019 Toshihiro Goto. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController {
private let cameraNode = SCNNode()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene
        let scene = SCNScene(named: "art.scnassets/main.scn")!
        
        // create and add a camera to the scene
        
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 8.845834, y: 15.296521, z: 4.400922)
        cameraNode.eulerAngles = SCNVector3(x: -1.118888, y: 1.0198009, z: -3.4155067e-07)
        
        
        // ----------------------------------------------------
        // Image to geometry
        // ----------------------------------------------------
        
        let image = UIImage(named: "logo50")!
        let box = SCNBox(width: 0.05, height: 0.05, length: 0.05, chamferRadius: 0)
        
        let imageToGeoNode = SCNImageColorNode(image: image, imageWidth: 50, imageHeight: 50, geometry: box, geometoryOffsetX: 0.05, geometoryOffsetZ: 0.05)
        
        scene.rootNode.addChildNode(imageToGeoNode)
        
        // ----------------------------------------------------
        // Animation
        // ----------------------------------------------------
        var countUp = 0
        
        for i in 0 ..< imageToGeoNode.childNodes.count {
            let chiledNode = imageToGeoNode.childNodes[i]
            
            if i % 50 == 49 { countUp += 1 }
            let count = i % 50 + countUp
            
            let posX = chiledNode.position.x
            let posZ = chiledNode.position.z
            
            let firstWait:TimeInterval = Double(count) * 0.01
            let endWait:TimeInterval = Double((50*50) - count) * 0.0025
            
            let move1 = SCNAction.move(to: SCNVector3(posX, 3.0, posZ), duration: 0.5)
            let move2 = SCNAction.move(to: SCNVector3(posX, 1.0, posZ), duration: 0.5)
            let move3 = SCNAction.move(to: SCNVector3(posX, 2.0, posZ), duration: 0.5)
            let move4 = SCNAction.move(to: SCNVector3(posX, 0.0, posZ), duration: 0.5)
            move1.timingMode = .easeOut
            move2.timingMode = .easeIn
            move3.timingMode = .easeOut
            move4.timingMode = .easeIn
            
            chiledNode.runAction(
                SCNAction.repeatForever(
                    SCNAction.sequence([
                        SCNAction.wait(duration:firstWait),
                        move1,
                        move2,
                        move3,
                        SCNAction.wait(duration: endWait),
                        move4,
                        SCNAction.wait(duration: endWait)
                    ])
                )
            )
        }
        // ----------------------------------------------------
        
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = UIColor.black
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
    }
    
    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // check what nodes are tapped
        let p = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result = hitResults[0]
            
            // get its material
            let material = result.node.geometry!.firstMaterial!
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            
            // on completion - unhighlight
            SCNTransaction.completionBlock = {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                
                material.emission.contents = UIColor.black
                
                SCNTransaction.commit()
            }
            
            material.emission.contents = UIColor.red
            
            SCNTransaction.commit()
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

}


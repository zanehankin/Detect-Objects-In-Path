//
//  ARSceneManager.swift
//  Detect-Objects-In-Path
//
//  Created by Zane Hankin on 5/20/19.
//  Copyright © 2019 Zane Hankin. All rights reserved.

import Foundation
import ARKit

class ARSceneManager: NSObject{
    
    weak var sceneView: ARSCNView?
    private var planes = [UUID: Plane]()
    var existingVerticalPlane: ARHitTestResult.ResultType = []
    
    var ship: SCNNode? = nil
    
    func attach(to sceneView: ARSCNView){
        self.sceneView = sceneView
        self.sceneView!.delegate = self
        configureSceneView(self.sceneView!)
    }
    
    func displayDebugInfo(){
        sceneView?.showsStatistics = true
        sceneView?.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
    }
    
    private func configureSceneView(_ sceneView: ARSCNView) {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.vertical]
        configuration.isLightEstimationEnabled = true
        
        sceneView.session.run(configuration)
    }
}

extension ARSceneManager: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async {
            if(self.ship == nil){
                let shipScene = SCNScene(named: "art.scnassets/ship.scn")!
                self.ship = shipScene.rootNode.childNodes.first
                node.addChildNode(self.ship!)
                self.ship?.position = SCNVector3(x: 0, y: 0, z: -30)
                
                self.sceneView?.pointOfView?.addChildNode(self.ship!)
            }
            
            guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
            
            print("Found plane: \(planeAnchor)")
            
            let plane = Plane(anchor: planeAnchor)
            self.planes[anchor.identifier] = plane
            node.addChildNode(plane)
            
            print(planeAnchor.geometry.boundaryVertices)
            let point1 = planeAnchor.geometry.boundaryVertices[0]
            let point2 = planeAnchor.geometry.boundaryVertices[1]
            
            let nx1 = point1.x
            let nz1 = point1.z
            
            let nx2 = point2.x
            let nz2 = point2.z
            
            var ang = atan2(nz2-nz1, nx2-nx1)
            ang = ang * -180 / .pi
            print(ang)
            
            self.ship?.eulerAngles.z = ang
            
            //                if ang < 10{
            //                    print("GO Straight")
            //                }
            //
            //                else{
            //                    print("Turn!")
            //                }
            ///HOW CAN YOU UPDATE THE EULER ANGLE AS IT IS CALCULATED? I WANT THE ARRROW TO MOVE FLUIDLY
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        if let plane = planes[planeAnchor.identifier] {
            plane.updateWith(anchor: planeAnchor)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        
        planes.removeValue(forKey: anchor.identifier)
        node.enumerateChildNodes { (ship, _) in
            ship.removeFromParentNode()
        }
    }
    
    func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: sceneView)
        let hitResults = sceneView?.hitTest(location, options: nil)
        if hitResults!.count > 0 {
            print("touched")
            
            self.ship?.eulerAngles.z = 0
        }
    }
}


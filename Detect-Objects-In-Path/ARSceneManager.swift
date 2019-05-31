//
//  ARSceneManager.swift
//  Detect-Objects-In-Path
//
//  Created by Zane Hankin on 5/20/19.
//  Copyright © 2019 Zane Hankin. All rights reserved.
//

import Foundation
import ARKit

class ARSceneManager: NSObject{
    
    weak var sceneView: ARSCNView?
    private var planes = [UUID: Plane]()
    var existingVerticalPlane: ARHitTestResult.ResultType = []
    
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
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        print("Found plane: \(planeAnchor)")
        
        let plane = Plane(anchor: planeAnchor)
        planes[anchor.identifier] = plane
        node.addChildNode(plane)
        
        print(planeAnchor.geometry.boundaryVertices)
        let point1 = planeAnchor.geometry.boundaryVertices[0]
        let point2 = planeAnchor.geometry.boundaryVertices[1]
        g
        let nx1 = point1.x
        let nz1 = point1.z
        
        let nx2 = point2.x
        let nz2 = point2.z

        var ang = atan2(nz2-nz1, nx2-nx1)
        ang = ang * 180 / .pi
        print(ang)
        
        
        

        //Use an arrow to be positioned at the angle of the viewer and then to turn until the angles = one another
}
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        if let plane = planes[planeAnchor.identifier] {
            plane.updateWith(anchor: planeAnchor)
        }
        
        
        
//        if let plane = SCNPlane(width: CGFloat(ARPlaneAnchor.extent.x), height: CGFloat(ARPlaneAnchor.extent.z)){
////            anchor.extent.z < 100
//            print("Turn!")
//        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        planes.removeValue(forKey: anchor.identifier)
    }
    
}

//        determine angle of rotation from Swift in ARKit
//        var existingPlane: ARHitTestResult.ResultType { get }
//        if let results = sceneView.hitTest(ARPlaneAnchor, [.existingVerticalPlaneUsingGeometry]){

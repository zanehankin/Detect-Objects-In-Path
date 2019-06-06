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
    
    var sentence = ""
    
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
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor){
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
            
            let roundedAng = String(format: "%.2f", abs(90-ang))
            
            //if rounded ang is < 90 turn the euler ang towards 90?
            
            //needs to be 90 degrees
            var EAngle = (90-ang)
            self.ship?.eulerAngles.z = abs(EAngle)
            
//            if EAngle < -80 || EAngle < 80{
//                EAngle += 1
//                self.ship?.eulerAngles.z = EAngle
//            }
            
            if ang < 0 || ang < -80 {
                print("Turn Left")
                self.sentence = "Turn Left \(roundedAng) Degrees"
                self.speakText()
            }
                
            else if ang > 0 || ang < 80{
                print("Turn Right")
                self.sentence = "Turn Right\(roundedAng) Degrees"
                self.speakText()
            }
                
            else{
                print("Back Up and Turn 90 Degrees")
                self.sentence = "Back Up and Turn 90 Degrees"
                self.speakText()
            }
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
    
    func speakText(){
        let synth = AVSpeechSynthesizer()
        let utterance = AVSpeechUtterance(string: sentence)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        
        if(!synth.isSpeaking){
            synth.speak(utterance)
        }
    }
}

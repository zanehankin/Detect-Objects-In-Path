//
//  ARSceneManager.swift
//  Detect-Objects-In-Path
//
//  Created by Zane Hankin on 5/20/19.
//  Copyright © 2019 Zane Hankin. All rights reserved.

import Foundation
import ARKit

class ARSceneManager: NSObject{
    
    var sceneView: ARSCNView?
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
    //    var camera = SCNCamera?
    
    var startingPositionNode: SCNNode?
    var endingPositionNode: SCNCamera?
    
    let RelPosition = SCNVector3Make(0,0,-0.1)
    
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
            print("nx1: ", nx1)
            print("nz1: ", nz1)
            
            let nx2 = point2.x
            let nz2 = point2.z
            print("nx2: ", nx2)
            print("nz2: ", nz2)
            
            var ang = atan2(nz2-nz1, nx2-nx1)
            ang = ang * -180 / .pi
            print("ang: ", ang)
            
            let EAngle = (90-ang)
            print("EAngle: ", EAngle)
            
            let roundedAng = String(format: "%.2f", EAngle)
            print("roundedAng: ", roundedAng)
            
            self.ship?.eulerAngles.z = abs(EAngle)
            
            if EAngle < 0 && EAngle > -80 {
                print("Turn Left")
                self.sentence = "Turn Left \(roundedAng) Degrees"
                self.speakText()
            }
                
            else if EAngle > 0 && EAngle < 80{
                print("Turn Right")
                self.sentence = "Turn Right\(roundedAng) Degrees"
                self.speakText()
            }
                
            else{
                print("Back Up and Turn Around 90 Degrees")
                self.sentence = "Back Up and Turn 90 Degrees"
                self.speakText()
            }
        }
    }
    
    //    func addNode(){
    //
    //        let shapeNode = SCNNode()
    //        shapeNode.geometry = SCNTube(innerRadius: 0.10, outerRadius: 0.10, height: 0.10)
    //        shapeNode.position = SCNVector3Make(0, 0, 0)
    //    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        if let plane = planes[planeAnchor.identifier] {
            plane.updateWith(anchor: planeAnchor)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        planes.removeValue(forKey: anchor.identifier)
        node.enumerateChildNodes {
            (ship, _) in
            ship.removeFromParentNode()
        }
    }
    
    func speakText(){
        let synth1 = AVSpeechSynthesizer()
        let utterance = AVSpeechUtterance(string: sentence)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        
        if(!synth1.isSpeaking){
            synth1.speak(utterance)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        if startingPositionNode != nil && endingPositionNode != nil {
            return
        }
        
        guard let xDist = CalculatingDistance.distance(fromStartingPositionNode: startingPositionNode, view: sceneView!, RelPosition: RelPosition)?.x else {return}
        
        guard let yDist = CalculatingDistance.distance(fromStartingPositionNode: startingPositionNode, view: sceneView!, RelPosition: RelPosition)?.y else {return}
        
        guard let zDist = CalculatingDistance.distance(fromStartingPositionNode: startingPositionNode, view: sceneView!, RelPosition: RelPosition)?.z else {return}
        
        DispatchQueue.main.async {
//            var distSentence = String(format:"Distance: %.2f", CalculatingDistance.distance(x: xDist, y: yDist, z: zDist)) + "m"
            
            let distExt = CalculatingDistance()
            
            let distSentence = String(format: "%.2f", distExt.ReturnDistance(x: xDist, y: yDist, z: zDist))
            
            print("distSentence: ", distSentence)
            
//            func speakDist(){
//                let synth2 = AVSpeechSynthesizer()
//                let utterance = AVSpeechUtterance(string: distSentence)
//                utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                
                
                /* How to write an if statement to talk when the value is below a certain value?*/
//                print (CalculatingDistance.dist)
                
                //                if (dist < 2){
                //                    synth.speak(utterance)
                //                }
                
                //                else if(
                
                //                if(!synth.isSpeaking){
                //                        synth.speak(utterance)
                //                }
            }
        }
    }




//DispatchQueue.main.asyncAfter(deadline: .now() + 2.5){
//    self.ship!.removeFromParentNode()
//
//}

//            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5){
//                let EAngle = (90)
//                self.ship?.eulerAngles.z = Float(abs(EAngle))
//            }

//            func removeFromParent(){
//                node.removeChildNode(self.ship!)
//                node.removeChildNode(plane)
//            }

/* Below is the code that removes the node. The problem is that I don't know how to then re-add an arrow node*/
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5){
//                self.ship!.removeFromParentNode()
//            }
/* */

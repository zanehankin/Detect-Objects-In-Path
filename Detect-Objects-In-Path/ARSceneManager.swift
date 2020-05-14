//
//  ARSceneManagerViewController.swift
//
//  Detect-Objects-In-Path
//
//  Created by Zane Hankin on 5/15/19.
//  Copyright © 2019 Zane Hankin. All rights reserved.
//
//Help from tutorial https://collectiveidea.com/blog/archives/2018/04/30/part-1-arkit-wall-and-plane-detection-for-ios-11.3, Paul Way, and Jack Welch
//
import Foundation
import UIKit
import SceneKit
import ARKit
import AVFoundation

class ARSceneManager: NSObject {
    
    var sceneView: ARSCNView = {
        let view = ARSCNView()
        return view
    }()
    
    private var planes = [UUID: Plane]()
    var existingVerticalPlane: ARHitTestResult.ResultType = []
    
    var ship: SCNNode? = nil
    
    var sentence1 = ""
    var sentence2 = ""
    
    var startingPositionNode: SCNNode?
    var endingPosition: SCNPlane?
    
    var lastDeterminedAngle = 0
    
    // endingPositionNode will be positioned at the camera
    
    let camRelPosition = SCNVector3Make(0,0,0)
    let configuration = ARWorldTrackingConfiguration()
    
    func configureSceneView(_ sceneView: ARSCNView) {
        //            let cameraAlignment: ARConfiguration.WorldAlignment
        
        configuration.planeDetection = [.vertical]
        configuration.isLightEstimationEnabled = true
        
        sceneView.session.run(configuration)
    }
    
    func attach(to sceneView: ARSCNView){
        self.sceneView = sceneView
        self.sceneView.delegate = self
        configureSceneView(self.sceneView)
    }
    
    func displayDebugInfo(){
        sceneView.showsStatistics = true
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
    }
}

//

extension ARSceneManager: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor, point: CGPoint) {
        applyAngle(for: node, anchor: anchor, point: point)
    }
    
    func applyAngle(for node: SCNNode, anchor: ARAnchor, point: CGPoint){
        
        if(self.ship == nil){
            let shipScene = SCNScene(named: "art.scnassets/ship.scn")!
            self.ship = shipScene.rootNode.childNodes.first
            node.addChildNode(self.ship!)
            
            ship?.childNode(withName: "shipTrue", recursively: true)
            
            self.ship?.position = SCNVector3(x: 0, y: 0, z: -30)
            self.sceneView.pointOfView?.addChildNode(self.ship!)
            /* Maybe make the ship nil so that it goes away?*/
            //            self.ship != nil
        }
        
        //        node.addChildNode(plane)
        
        let roundedAng = CheckAngles.checkAnglesFunc(for: node, anchor: anchor)
        
        let results = sceneView.hitTest(point, types: .existingPlane)
        
            if results.count < 1 {
                self.ship?.eulerAngles.z = roundedAng
            }
                
            else {
                self.ship?.eulerAngles.z = 0
                print ("Angle Reset")
            }
        
        if roundedAng < 0 && roundedAng > -80 {
            print("Turn Left")
            self.sentence1 = "Turn Left \(roundedAng) Degrees"
            self.speakText()
        }
            
        else if roundedAng > 0 && roundedAng < 80{
            print("Turn Right")
            self.sentence1 = "Turn Right\(roundedAng) Degrees"
            self.speakText()
        }
            
        else{
            print("Turn 90 Degrees")
            self.sentence1 = "Turn 90 Degrees"
            self.speakText()
        }
    }
    
    func speakText(){
        let synth1 = AVSpeechSynthesizer()
        let sentence = "\(sentence1) \(sentence2)"
        let utterance = AVSpeechUtterance(string: sentence)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        
        if(!synth1.isSpeaking){
            synth1.speak(utterance)
        }
    }
    
    func addBoxSNode(){
        let boxS = SCNBox(width: 2.0, height: 2.0, length: 2.0, chamferRadius: 0)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        boxS.materials = [material]
        let boxENode = SCNNode(geometry: boxS)
        
        //            boxENode.position = SCNVector3Make(0, 0, 0)
        
        sceneView.scene.rootNode.addChildNode(boxENode)
        print("box node added")
        
        /* need to add a fukin box node to the ARPlane AND to the fuckin camera*/
    }
    
    func checkDistance(){
        if startingPositionNode == nil && endingPosition == nil{
            let boxS = SCNNode(geometry: SCNBox(width: 2.0, height: 2.0, length: 2.0, chamferRadius: 0))
            boxS.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
            //            boxS.position = camRelPosition
            boxS.camera = SCNCamera()
            boxS.position = SCNVector3()
            
            let plane = SCNPlane()
            
            CalculatingDistance.addBoxChildNode(boxS, toNode: sceneView.scene.rootNode, inView: sceneView, camRelPosition: camRelPosition)
            self.sceneView.pointOfView?.addChildNode(boxS)
            
            startingPositionNode = boxS
            endingPosition = plane
        }
            
        else {return}
        
        guard let xDist = CalculatingDistance.distance(fromStartingPositionNode: startingPositionNode, onView: sceneView, camRelPosition: camRelPosition)?.x else {return}
        guard let yDist = CalculatingDistance.distance(fromStartingPositionNode: startingPositionNode, onView: sceneView, camRelPosition: camRelPosition)?.y else {return}
        guard let zDist = CalculatingDistance.distance(fromStartingPositionNode: startingPositionNode, onView: sceneView, camRelPosition: camRelPosition)?.z else {return}
        
        DispatchQueue.main.async {
            let distSentence = String(format: "%.2f", CalculatingDistance.ReturnDistance(x: xDist, y: yDist, z: zDist))
            print("distSentence: ", distSentence)
            self.sentence2 = "Object is within \(distSentence) meters"
            self.speakText()
        }
    }
    
    /* Can I run this hit test outside of the func? */
    func hitTest(_ point: CGPoint, types: ARHitTestResult.ResultType) {
        let results = sceneView.hitTest(point, types: .existingPlane)
        
        if results.count > 1 {
            sceneView.session.pause()
            
            ship?.removeFromParentNode()
            planes.removeAll()
            print ("Objects REMOVED")
            
            sceneView.session.run(configuration, options: [.removeExistingAnchors])
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval, node: SCNNode, for anchor: ARAnchor, point: CGPoint) {
        if (Int(time) - lastDeterminedAngle > 3){
            applyAngle(for: node, anchor: anchor, point: point)
            speakText()
            checkDistance()
            
            lastDeterminedAngle = Int(time)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        if let plane = planes[planeAnchor.identifier] {
            plane.updateWith(anchor: planeAnchor)
        }
    }
    
    /* use this to "reset" scene? Remove the certain anchors and nodes??*/
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        planes.removeValue(forKey: anchor.identifier)
        node.enumerateChildNodes {
            (ship, _) in
            ship.removeFromParentNode()
        }
    }
}

/* This is the end of the file's active code*/



/* Possible code/ notes are down below: */
//        DispatchQueue.main.async {
//            var distSentence = String(format:"Distance: %.2f", CalculatingDistance.distance(x: xDist, y: yDist, z: zDist)) + "m"

//            let distExt = CalculatingDistance()

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
// }


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

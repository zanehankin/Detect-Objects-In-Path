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
    
    var sentence = ""
    
    var startingPositionNode: SCNNode?
    var endingPosition: SCNPlane?
    
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

extension ARSceneManager: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor){
        //    DispatchQueue.main.async {
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
        
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        print("Found plane: \(planeAnchor)")
        
        let plane = Plane(anchor: planeAnchor)
        //        let planeName = plane.name
        //        plane.name = "nameTest"
        
        self.planes[anchor.identifier] = plane
        node.addChildNode(plane)
        //        addBoxENode()
        
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
        
        let deltaNX = nx2-nx1
        let deltaNZ = nz2-nz1
        
        let ang = atan2(deltaNZ, deltaNX)
        //            ang = ang * -180 / .pi
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
            print("Turn 90 Degrees")
            self.sentence = "Turn 90 Degrees"
            self.speakText()
        }
        //    }
    }
    
    func speakText(){
        let synth1 = AVSpeechSynthesizer()
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
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        //        var checkPlaneAnchor = false
        //        sceneView.scene.rootNode.enumerateChildNodes
        //                if planeName == "planeTest"{
        //                checkPlaneAnchor = true
        //            }
        //        }
        //
        //        if planeName == "planeTest"{
        //            endingPositionNode != nil
        //            startingPositionNode != nil
        //        }
        
        //       if startingPositionNode != nil && endingPositionNode == nil{
        //            let box = SCNNode(geometry: SCNBox(width: 2.1, height: 2.1, length: 2.1, chamferRadius: 0))
        //            box.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        //
        //            CalculatingDistance.addBoxChildNode(box, toNode: sceneView.scene.rootNode, inView: sceneView, camRelPosition: camRelPosition)
        //
        //            endingPositionNode = box
        //        }
        
        //attach to plane annchor?
        //if statement to only add square when plane anchor is added
        //distance from planeanchor ONLY
        
        if startingPositionNode == nil && endingPosition == nil{
            let boxS = SCNNode(geometry: SCNBox(width: 2.0, height: 2.0, length: 2.0, chamferRadius: 0))
            boxS.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
            //            boxS.position = camRelPosition
            boxS.camera = SCNCamera()
            boxS.position = SCNVector3()
            
            let plane = SCNPlane()
            
            /* Can I run the function that adds Planes?? Do I need to??*/
            
            //            let boxS = sceneView.pointOfView?.position
            
            /* ?? What is 'toNode:' ?? */
            
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
        }
    }
    
    /* IF there is a plane node and ship node, THEN you can reset it*/
    /*NEED TO CALL TO THIS FUNCTION SOMEWHERE!!*/
    func resetScene() {
        sceneView.session.pause()
        
        if(self.ship != nil){
            ship?.removeFromParentNode()
            planes.removeAll()
            print ("Ship Is NIL")
        }
            
        else {return}
        
        //        sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
        //
        ////            planes.removeAll()
        //        }
        sceneView.session.run(configuration, options: [.removeExistingAnchors])
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

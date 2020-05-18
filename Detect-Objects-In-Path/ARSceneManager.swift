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
import ARKit

class ARSceneManager: NSObject {
    private var planes = [UUID: Plane]()
    
    var sceneView: ARSCNView = {
        let view = ARSCNView()
        return view
    }()
    
    //    var existingVerticalPlane: ARHitTestResult.ResultType = []
    
    var ship: SCNNode? = nil
    
    var sentence1 = ""
    var sentence2 = ""
    
    private var startingPositionNode: SCNNode?
    private var endPositionNode: SCNNode?
    
    //    var lastDeterminedAngle = 0
    
    let camRelPosition = SCNVector3Make(0,0,0)
    let configuration = ARWorldTrackingConfiguration()
    
    func attach(to sceneView: ARSCNView){
        self.sceneView = sceneView
        self.sceneView.delegate = self
        configureSceneView(self.sceneView)
    }
    
    private func configureSceneView(_ sceneView: ARSCNView) {
        
        configuration.planeDetection = [.vertical]
        /* DIS??*/
        configuration.isLightEstimationEnabled = true
        /* DIS?^*/
        //        sceneView.autoenablesDefaultLighting = true
        sceneView.session.run(configuration)
    }
    
    func displayDebugInfo(){
        sceneView.showsStatistics = true
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }
}

//


extension ARSceneManager: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        //        DispatchQueue.main.async {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        print("Found plane: \(planeAnchor)")
        let plane = Plane(anchor: planeAnchor)
        self.planes[anchor.identifier] = plane
        node.addChildNode(plane)
        plane.position = SCNVector3()
        
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
        
        var ang = atan2(deltaNZ, deltaNX)
        
        ang = ang * -180 / .pi
        
        print("ang: ", ang)
        
        let EAngle = (90-ang)
        print("EAngle: ", EAngle)
        
        let roundedAng = String(format: "%.2f", EAngle)
        print("roundedAng: ", roundedAng)
        
        if (self.ship == nil) {
            let shipScene = SCNScene(named: "art.scnassets/ship.scn")!
            self.ship = shipScene.rootNode.childNodes.first
            //                node.addChildNode(self.ship!)
            self.sceneView.scene.rootNode.addChildNode(self.ship!)
            self.ship?.position = SCNVector3(x: 0, y: 0, z: -30)
            self.sceneView.pointOfView?.addChildNode(self.ship!)
            /* Maybe make the ship nil so that it goes away?*/
        }
            
        else { print ("Else HitTestResult") }
        
        //        DispatchQueue.main.async {
        //        let hitTestResult = sceneView.hitTest(point, types: .existingPlaneUsingGeometry)
        //        if hitTestResult.count < 10 {
        //            self.ship?.eulerAngles.z = EAngle
        //        }
        
        self.ship?.eulerAngles.z = EAngle
        
        if (EAngle < 0 && EAngle > -80) {
            print("Turn Left \(roundedAng) Degrees")
            self.sentence1 = "Turn Left \(roundedAng) Degrees"
            self.speakText()
        }
            
        else if (EAngle > 0 && EAngle < 80) {
            print("Turn Right \(roundedAng) Degrees")
            self.sentence1 = "Turn Right \(roundedAng) Degrees"
            self.speakText()
        }
            
        else {
            print("Turn 90 Degrees")
            self.sentence1 = "Turn 90 Degrees"
            self.speakText()
        }
        
        /* Below is the code for determining distance*/
        
        if (self.startingPositionNode != nil && self.endPositionNode != nil) {
            self.startingPositionNode?.removeFromParentNode()
            self.endPositionNode?.removeFromParentNode()
            self.startingPositionNode = nil
            self.endPositionNode = nil
        }
            //
        else if (self.startingPositionNode == nil && self.endPositionNode == nil) {
            let boxS = SCNNode(geometry: SCNBox(width: 2.0, height: 2.0, length: 2.0, chamferRadius: 0))
            boxS.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
            boxS.camera = SCNCamera()
            boxS.position = SCNVector3()
            CalculatingDistance.addBoxChildNode(boxS, toNode: self.sceneView.scene.rootNode, inView: self.sceneView, camRelPosition: self.camRelPosition)
            self.sceneView.pointOfView?.addChildNode(boxS)
            
            
            let boxE = SCNNode(geometry: SCNBox(width: 2.0, height: 2.0, length: 2.0, chamferRadius: 0))
            boxE.geometry?.firstMaterial?.diffuse.contents = UIColor.red
            boxE.position = plane.position
            
            CalculatingDistance.addBoxChildNode(boxE, toNode: self.sceneView.scene.rootNode, inView: self.sceneView, camRelPosition: self.camRelPosition)
            self.sceneView.scene.rootNode.addChildNode(boxE)
            
            self.startingPositionNode = boxS
            self.endPositionNode = boxE
            
        }
            
        else {return}
        
        guard let xDist = CalculatingDistance.distance(fromStartingPositionNode: self.endPositionNode, onView: self.sceneView, camRelPosition: self.camRelPosition)?.x else {return}
        guard let yDist = CalculatingDistance.distance(fromStartingPositionNode: self.endPositionNode, onView: self.sceneView, camRelPosition: self.camRelPosition)?.y else {return}
        guard let zDist = CalculatingDistance.distance(fromStartingPositionNode: self.endPositionNode, onView: self.sceneView, camRelPosition: self.camRelPosition)?.z else {return}
        
        let distSentence = String(format: "%.2f", CalculatingDistance.ReturnDistance(x: xDist, y: yDist, z: zDist))
        print("distSentence: ", distSentence)
        self.sentence2 = "Object is within \(distSentence) meters"
        self.speakText()
        
            if (self.ship != nil) {
                delaySeconds(2) {
                    self.resetScene()
                }
            }
        
        // OR
        
//        if (self.ship != nil) {
//                DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
//                self.resetScene()
//            }
//        }

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
        //
        //
        /* Fix the delay so that the delay resets after the delay!!*/
        //
        //
    func delaySeconds(_ delay: Double, closure:@escaping ()->()) {
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
    }
    
    func resetScene(){
        sceneView.session.pause()
        ship?.removeFromParentNode()
        sceneView.session.run(configuration, options: [.removeExistingAnchors, .resetTracking])
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        if let plane = planes[planeAnchor.identifier] {
            plane.updateWith(anchor: planeAnchor)
        }
    }
    
    /* DO I NEED TO RUN A "RESET SCENE FUNCTION??*/
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor, point: CGPoint) {
        
        planes.removeValue(forKey: anchor.identifier)
        node.enumerateChildNodes {
            (ship, _) in
            ship.removeFromParentNode()
        }
    }
}

/* This is the end of the file's active code*/



/* Possible code/ notes are down below: */

//    func checkDistance(for plane: Plane, for anchor: ARPlaneAnchor){
//        guard let xDist = CalculatingDistance.distance(fromStartingPositionNode: startingPositionNode, onView: sceneView, camRelPosition: camRelPosition)?.x else {return}
//        guard let yDist = CalculatingDistance.distance(fromStartingPositionNode: startingPositionNode, onView: sceneView, camRelPosition: camRelPosition)?.y else {return}
//        guard let zDist = CalculatingDistance.distance(fromStartingPositionNode: startingPositionNode, onView: sceneView, camRelPosition: camRelPosition)?.z else {return}
//
//        DispatchQueue.main.async {
//            let distSentence = String(format: "%.2f", CalculatingDistance.ReturnDistance(x: xDist, y: yDist, z: zDist))
//            print("distSentence: ", distSentence)
//            self.sentence2 = "Object is within \(distSentence) meters"
//            self.speakText()
//        }
//
//        if startingPositionNode != nil && endPositionNode != nil {
//            startingPositionNode?.removeFromParentNode()
//            endPositionNode?.removeFromParentNode()
//            startingPositionNode = nil
//            endPositionNode = nil
//        }
//
//        else if startingPositionNode == nil && endPositionNode == nil {
//            let boxS = SCNNode(geometry: SCNBox(width: 2.0, height: 2.0, length: 2.0, chamferRadius: 0))
//            boxS.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
//            boxS.camera = SCNCamera()
//            boxS.position = SCNVector3()
//            CalculatingDistance.addBoxChildNode(boxS, toNode: sceneView.scene.rootNode, inView: sceneView, camRelPosition: camRelPosition)
//            self.sceneView.pointOfView?.addChildNode(boxS)
//
//
//            let boxE = SCNNode(geometry: SCNBox(width: 2.0, height: 2.0, length: 2.0, chamferRadius: 0))
//            boxE.geometry?.firstMaterial?.diffuse.contents = UIColor.red
//            boxE.position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
//            CalculatingDistance.addBoxChildNode(boxE, toNode: sceneView.scene.rootNode, inView: sceneView, camRelPosition: camRelPosition)
//            sceneView.scene.rootNode.addChildNode(boxE)
//
//            startingPositionNode = boxS
//            endPositionNode = boxE
//        }
//
//        else {return}
//
//    }

/* Can I run this hit test outside of the func? */
//    func hitTest(_ point: CGPoint, types: ARHitTestResult.ResultType) {
//        let results = sceneView.hitTest(point, types: .existingPlaneUsingExtent)
//
//        if results.count > 2 {
//            sceneView.session.pause()
//
//            ship?.removeFromParentNode()
//            planes.removeAll()
//            print ("Objects REMOVED")
//
//            sceneView.session.run(configuration, options: [.removeExistingAnchors])
//        }
//    }

//    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval, node: SCNNode, for anchor: ARPlaneAnchor, point: CGPoint) {

//        guard let xDist = CalculatingDistance.distance(fromStartingPositionNode: startingPositionNode, onView: sceneView, camRelPosition: camRelPosition)?.x else {return}
//        guard let yDist = CalculatingDistance.distance(fromStartingPositionNode: startingPositionNode, onView: sceneView, camRelPosition: camRelPosition)?.y else {return}
//        guard let zDist = CalculatingDistance.distance(fromStartingPositionNode: startingPositionNode, onView: sceneView, camRelPosition: camRelPosition)?.z else {return}
//
//        DispatchQueue.main.async {
//            let dist = CalculatingDistance.ReturnDistance(x: xDist, y: yDist, z: zDist)
//            let distSentence = String(format: "%.2f", dist)
//
//            print("distSentence: ", distSentence)
//            self.sentence2 = "Object is within \(distSentence) meters"
//            self.speakText()
//        }
//
//        if startingPositionNode != nil && endPositionNode != nil {
//            startingPositionNode?.removeFromParentNode()
//            endPositionNode?.removeFromParentNode()
//            startingPositionNode = nil
//            endPositionNode = nil
//        }
//
//        else if startingPositionNode == nil && endPositionNode == nil {
//            let boxS = SCNNode(geometry: SCNBox(width: 2.0, height: 2.0, length: 2.0, chamferRadius: 0))
//            boxS.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
//            boxS.camera = SCNCamera()
//            boxS.position = SCNVector3()
//            CalculatingDistance.addBoxChildNode(boxS, toNode: sceneView.scene.rootNode, inView: sceneView, camRelPosition: camRelPosition)
//            self.sceneView.pointOfView?.addChildNode(boxS)
//
//
//            let boxE = SCNNode(geometry: SCNBox(width: 2.0, height: 2.0, length: 2.0, chamferRadius: 0))
//            boxE.geometry?.firstMaterial?.diffuse.contents = UIColor.red
//            boxE.position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
//            CalculatingDistance.addBoxChildNode(boxE, toNode: sceneView.scene.rootNode, inView: sceneView, camRelPosition: camRelPosition)
//            sceneView.scene.rootNode.addChildNode(boxE)
//
//            startingPositionNode = boxS
//            endPositionNode = boxE
//        }
//
//        else {return}
//        //            lastDeterminedAngle = Int(time)
//    }


//    func applyAngle(for node: SCNNode, anchor: ARAnchor, point: CGPoint){

//        if(self.ship == nil){
//            let shipScene = SCNScene(named: "art.scnassets/ship.scn")!
//            self.ship = shipScene.rootNode.childNodes.first
//            node.addChildNode(self.ship!)
//
//            ship?.childNode(withName: "shipTrue", recursively: true)
//
//            self.ship?.position = SCNVector3(x: 0, y: 0, z: -30)
//            self.sceneView.pointOfView?.addChildNode(self.ship!)
//            /* Maybe make the ship nil so that it goes away?*/
//            //            self.ship != nil
//        }

//        node.addChildNode(plane)

//        let roundedAng = checkAnglesFunc(for: node, anchor: anchor)
//        var roundedAng = String(format: "%.2f", ang)

/*DOWN BELOW*/
//        let results = sceneView.hitTest(point, options: nil)
//
//        if results.count <= 1 {
//            self.ship?.eulerAngles.z = roundedAng
//        }

//        else {
//            self.ship?.eulerAngles.z = 0
//            print ("Angle Reset")
//        }
//        self.ship?.eulerAngles.z = roundedAng
//
//        if roundedAng < 0 && roundedAng > -80 {
//            print("Turn Left")
//            self.sentence1 = "Turn Left \(roundedAng) Degrees"
//            self.speakText()
//        }
//
//        else if roundedAng > 0 && roundedAng < 80{
//            print("Turn Right")
//            self.sentence1 = "Turn Right\(roundedAng) Degrees"
//            self.speakText()
//        }
//
//        else{
//            print("Turn 90 Degrees")
//            self.sentence1 = "Turn 90 Degrees"
//            self.speakText()
//        }
//    }

//        self.checkDistance(for: node as! Plane, for: anchor as! ARPlaneAnchor)
//        applyAngle(for: node, anchor: anchor, point: point)

//    func checkAnglesFunc(for node: SCNNode, anchor: ARAnchor) -> Float{

//        checkDistance()
/* DO I need to set a new variable to say "check if the angle matches this "locked in angle"?"*/
//        if (Int(time) - lastDeterminedAngle > 5){
//        plane(for: node, for: anchor)
//        applyAngle(for: node, anchor: anchor, point: point)
//        checkDistance(for: node as! Plane, for: anchor as! ARPlaneAnchor)


//    func addBoxSNode(){
//        let boxS = SCNBox(width: 2.0, height: 2.0, length: 2.0, chamferRadius: 0)
//        let material = SCNMaterial()
//        material.diffuse.contents = UIColor.red
//        boxS.materials = [material]
//        let boxENode = SCNNode(geometry: boxS)
//
//        //            boxENode.position = SCNVector3Make(0, 0, 0)
//
//        sceneView.scene.rootNode.addChildNode(boxENode)
//        print("box node added")
//
//        /* need to add a fukin box node to the ARPlane AND to the fuckin camera*/
//    }


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

//
//  Plane.swift
//  Detect-Objects-In-Path
//
//  Created by Zane Hankin on 5/23/19.
//  Copyright © 2019 Zane Hankin. All rights reserved.
//

import Foundation
import ARKit

class Plane: SCNNode {
    
    let plane: SCNPlane
    
    init(anchor: ARPlaneAnchor) {
        plane = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
        
        super.init()
        
        plane.cornerRadius = 0.005
        plane.materials = [GridMaterial()]
        
        let planeNode = SCNNode(geometry: plane)
        
        planeNode.position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
        planeNode.eulerAngles.x = -.pi / 2
        planeNode.opacity = 0.25
        addChildNode(planeNode)
        planeNode.name = "planeTest"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateWith(anchor: ARPlaneAnchor) {
        plane.width  = CGFloat(anchor.extent.x)
        plane.height = CGFloat(anchor.extent.z)
        
        position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
        
        if let grid = plane.materials.first as? GridMaterial {
            grid.updateWith(anchor: anchor)
        }
    }
    
    func returnPlanePosition(anchor: ARPlaneAnchor) -> SCNVector3 {
        let planePosition = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
        return planePosition
    }
}

/* This is the end of the file's active code*/



//extension Plane: ARSCNViewDelegate{

//    func addBoxEToPlane(){
//        let boxE = SCNNode(geometry: SCNBox(width: 2.0, height: 2.0, length: 2.0, chamferRadius: 0))
//        boxE.geometry?.firstMaterial?.diffuse.contents = UIColor.red
//    }
//
//     func addBoxENodeToPlane(anchor: ARPlaneAnchor){
//        let XCoord = (plane.width)/2
//        let YCoord = (plane.height)/2
//        let ZCoord = (anchor.extent.z)
//
////        let boxE = SCNBox()
////        let material = SCNMaterial()
////        material.diffuse.contents = UIColor.red
////        boxE.materials = [material]
////        let boxENode = SCNNode(geometry: boxE)
////        boxE.position = SCNVector3Make(Float(XCoord), Float(YCoord), ZCoord)
//
//        let boxPreE = SCNBox(width: 2.0, height: 2.0, length: 2.0, chamferRadius: 0)
//        let material = SCNMaterial()
//        material.diffuse.contents = UIColor.red
//        boxPreE.materials = [material]
//        let boxENode = SCNNode(geometry: boxPreE)
//        boxENode.position = SCNVector3Make(Float(XCoord), Float(YCoord), ZCoord)
//
//        print("box node added")

//            boxENode.position = SCNVector3Make(0, 0, 0)

//                sceneView.scene.rootNode.addChildNode(boxENode)

/* need to add a fukin box node to the ARPlane AND to the fuckin camera*/

//    func checkBox(){
//        if SCNBox == true {
//
//        }
//        print("box node added")
//    }


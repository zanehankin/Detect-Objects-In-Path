//
//  CalculatingDistance.swift
//  Detect-Objects-In-Path
//
//  Created by Zane Hankin on 5/6/20.
//  Copyright © 2020 Zane Hankin. All rights reserved.
//

import Foundation
import UIKit
import ARKit

class CalculatingDistance: NSObject{
    
    static func addBoxChildNode (_ node: SCNNode, toNode: SCNNode, inView: ARSCNView, camRelPosition: SCNVector3){
        
        guard let currentFrame = inView.session.currentFrame else {return}
        
        let camera = currentFrame.camera
        let transform = camera.transform
        
        var translateMatrix = matrix_identity_float4x4
        
        translateMatrix.columns.3.x = camRelPosition.x
        translateMatrix.columns.3.y = camRelPosition.y
        translateMatrix.columns.3.z = camRelPosition.z
        
        let newMatrix = simd_mul(transform, translateMatrix)
        node.simdTransform = newMatrix
        toNode.addChildNode(node)
    }
    
    static func distance (fromStartingPositionNode: SCNNode?, onView: ARSCNView, camRelPosition: SCNVector3) -> SCNVector3? {
        
        guard let startingPosition = fromStartingPositionNode else {return nil}
        
        guard let currentFrame = onView.session.currentFrame else {return nil}
        
        let camera = currentFrame.camera
        let transform = camera.transform
        
        var translateMatrix = matrix_identity_float4x4
        //^derived from stackoverflow explanation on accessing coordinates using the camera
        
        translateMatrix.columns.3.x = camRelPosition.x
        translateMatrix.columns.3.y = camRelPosition.y
        translateMatrix.columns.3.z = camRelPosition.z
        
        let newMatrix = simd_mul(transform, translateMatrix)
        /* Accesing the coordinates of the matrices with the camera. "transform" accesses real world coordinates, allowing the data to find dist  */
        
        let xDist = newMatrix.columns.3.x - startingPosition.position.x
        let yDist = newMatrix.columns.3.y - startingPosition.position.y
        let zDist = newMatrix.columns.3.z - startingPosition.position.z
        
        return SCNVector3(xDist, yDist, zDist)
    }
    
    static func ReturnDistance(x: Float, y: Float, z: Float) -> Float {
        
        let dist = (sqrtf(x*x + y*y + z*z))
        
        return dist
    }
}

/* This is the end of the file*/



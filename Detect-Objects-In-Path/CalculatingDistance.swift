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
    
   static func distance (fromStartingPositionNode: SCNNode?, view: ARSCNView, RelPosition: SCNVector3) -> SCNVector3? {
        
        guard let startingPosition = fromStartingPositionNode else {return nil}
        
        guard let currentFrame = view.session.currentFrame else {return nil}
        
        let camera = currentFrame.camera
        
        let transform = camera.transform
        
        var matrices = matrix_identity_float4x4
        //^derived from stackoverflow explanation on accessing coordinates using the camera
        
        matrices.columns.3.x = RelPosition.x
        matrices.columns.3.y = RelPosition.y
        matrices.columns.3.z = RelPosition.z
        
        let modifiedMatrix = simd_mul(transform, matrices)
        /* Accesing the coordinates of the matrices with the camera. "transform" accesses real world coordinates, allowing the data to find dist  */
        
        let xDist = modifiedMatrix.columns.3.x - startingPosition.position.x
        let yDist = modifiedMatrix.columns.3.y - startingPosition.position.y
        let zDist = modifiedMatrix.columns.3.z - startingPosition.position.z
        
        return SCNVector3(xDist, yDist, zDist)
    }
    
    func ReturnDistance(x: Float, y: Float, z: Float) -> Float {
        
        let dist = (sqrtf(x*x + y*y + z*z))
        
        return dist
    }
}

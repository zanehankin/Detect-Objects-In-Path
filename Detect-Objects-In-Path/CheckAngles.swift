//
//  CheckAngles.swift
//  Detect-Objects-In-Path
//
//  Created by Zane Hankin on 5/14/20.
//  Copyright © 2020 Zane Hankin. All rights reserved.
//

import Foundation
import UIKit
import ARKit

class CheckAngles: ARAnchor {
    
    static func checkAnglesFunc(for node: SCNNode, anchor: ARAnchor) -> Float{
        
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return 0 }
        
        print("Found plane: \(planeAnchor)")
        
        let plane = Plane(anchor: planeAnchor)
        
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
        
        let deltaNX = nx2-nx1
        let deltaNZ = nz2-nz1
        
        var ang = atan2(deltaNZ, deltaNX)
        
        ang = ang * -180 / .pi
        /* Delete line above^ if need be*/
        print("ang: ", ang)
        
        let EAngle = (90-ang)
        print("EAngle: ", EAngle)

        return EAngle
    }
    
//    static func applyAngles(){
//
//    }
    
}

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
        
        let planePositionX = anchor.center.x
        let planePositionZ = anchor.center.z

        planeNode.position = SCNVector3Make(planePositionX, 0, planePositionZ)
        planeNode.eulerAngles.x = -.pi / 2
        planeNode.opacity = 0.25
        addChildNode(planeNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /* Use this to update new plane?*/
    func updateWith(anchor: ARPlaneAnchor) {
        
        plane.width  = CGFloat(anchor.extent.x)
        plane.height = CGFloat(anchor.extent.z)
        
        position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
        
        if let grid = plane.materials.first as? GridMaterial {
            grid.updateWith(anchor: anchor)
        }
    }
}

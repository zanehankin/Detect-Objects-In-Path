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
        planeNode.opacity = 0.15
        addChildNode(planeNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateWith(anchor: ARPlaneAnchor) {
        
        plane.width = CGFloat(anchor.extent.x)
        plane.height = CGFloat(anchor.extent.z)
        
        position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
        
        if let grid = plane.materials.first as? GridMaterial {
            grid.updateWith(anchor: anchor)
        }
    }
}

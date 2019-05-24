//
//  GridMaterial.swift
//  Detect-Objects-In-Path
//
//  Created by Zane Hankin on 5/23/19.
//  Copyright © 2019 Zane Hankin. All rights reserved.
//

import Foundation
import ARKit

class GridMaterial: SCNMaterial {
    
    override init() {
        super.init()
        
        let image = UIImage(named: "Grid")
        
        diffuse.contents = image
        diffuse.wrapS = .repeat
        diffuse.wrapT = .repeat
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateWith(anchor: ARPlaneAnchor) {
        
        /*
         Scene Kit uses meters for its measurements.
         In order to get the texture looking good we need to decide the amount of times we want it to repeat per meter.
         */
        
        let mmPerMeter: Float = 1000
        let mmOfImage: Float = 65
        let repeatAmount: Float = mmPerMeter / mmOfImage
        
        diffuse.contentsTransform = SCNMatrix4MakeScale(anchor.extent.x * repeatAmount, anchor.extent.z * repeatAmount, 1)
    }
}

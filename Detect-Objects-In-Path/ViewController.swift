//
//  ViewController.swift
//  Detect-Objects-In-Path
//
//  Created by Zane Hankin on 5/15/19.
//  Copyright © 2019 Zane Hankin. All rights reserved.
//
//  Help from tutorial https://collectiveidea.com/blog/archives/2018/04/30/part-1-arkit-wall-and-plane-detection-for-ios-11.3, Paul Way, and Jack Welch, https://developer.apple.com/, Stack Overflow posts
//

import UIKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    let sceneManager = ARSceneManager()
    
    var IsTouched = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        sceneManager.attach(to: sceneView)
        sceneManager.displayDebugInfo()
        print ("starting program")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: sceneView)
        let hitResults = sceneView?.hitTest(location, options: nil)
        if hitResults!.count > 0 {
            print("touched")
        }
    }
    
    
    
    
}

/* This is the end of the file's active code*/



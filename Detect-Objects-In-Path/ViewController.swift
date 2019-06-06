//
//  ViewController.swift
//  Detect-Objects-In-Path
//
//  Created by Zane Hankin on 5/15/19.
//  Copyright © 2019 Zane Hankin. All rights reserved.
//
//Helf from tutorial https://collectiveidea.com/blog/archives/2018/04/30/part-1-arkit-wall-and-plane-detection-for-ios-11.3
//

import UIKit
import SceneKit
import ARKit
import AVFoundation

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    let sceneManager = ARSceneManager()
    
    let command = "Turn"
    
    var IsTouched = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneManager.attach(to: sceneView)
        
        sceneManager.displayDebugInfo()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: sceneView)
        let hitResults = sceneView?.hitTest(location, options: nil)
        if hitResults!.count > 0 {
            print("touched")
            IsTouched = true
            
//        if ang > 100{
//           let sentance = command + "Left"
//            speakText()
//            }
//
//        else if ang < 80{
//            let sentance = command + "Right"
//            speakText()
//            }
//
//        else{
//            let sentance = "Continue Straight"
//            speakText()
//            }
        }
    }
    
    func speakText(){
        let synth = AVSpeechSynthesizer()
        let utterance = AVSpeechUtterance(string: command)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        
        if(!synth.isSpeaking){
            synth.speak(utterance)
        }
    }
}

//
//  ViewController.swift
//  AR Ruler
//
//  Created by Hanh Nguyen on 7/19/18.
//  Copyright © 2018 Hanh Nguyen. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var dotNodes = [SCNNode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)
            let results = sceneView.hitTest(touchLocation, types: .featurePoint)
            
            if let hitResult = results.first {
                addNode(atLocation: hitResult)
            }
        }
    }
    
    func addNode(atLocation location: ARHitTestResult){
        let nodeGeometry = SCNSphere(radius: 0.005)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        nodeGeometry.materials = [material]
        
        let node = SCNNode(geometry: nodeGeometry)
        node.position = SCNVector3(
            location.worldTransform.columns.3.x,
            location.worldTransform.columns.3.y,
            location.worldTransform.columns.3.z
        )
        sceneView.scene.rootNode.addChildNode(node)
        
        dotNodes.append(node)
        if dotNodes.count >= 2 {
            let startNode = dotNodes[dotNodes.count - 1]
            let distance = calculate(startNode: startNode, endNode: node)
            showDistance(distance: distance, position: node.position)
        }
    }
    
    func calculate(startNode: SCNNode, endNode: SCNNode) -> Float{
        let distance = sqrt(pow(startNode.position.x - endNode.position.x, 2) +
                            pow(startNode.position.y - endNode.position.y, 2) +
                            pow(startNode.position.z - endNode.position.y, 2)
        )
        
        return abs(distance)
    }
    
    func showDistance(distance: Float, position: SCNVector3){
        let textGeometry = SCNText(string: String(distance), extrusionDepth: 1.0)
        
        textGeometry.firstMaterial?.diffuse.contents = UIColor.red
        
        let textNode = SCNNode(geometry: textGeometry)
        textNode.position = SCNVector3(position.x, position.y + 0.01, position.z/2)
        textNode.scale = SCNVector3(0.01, 0.01, 0.01)
        
        sceneView.scene.rootNode.addChildNode(textNode)
    }
}

//
//  ViewController.swift
//  AR Ruller
//
//  Created by Nayan Khadase on 15/12/21.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {

    @IBOutlet var sceneView: ARSCNView!
    var dotNodes = [SCNNode]()
    var resultNode = SCNNode()

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

    @IBAction func clearAll(_ sender: UIBarButtonItem) {
        if !dotNodes.isEmpty{
            for dot in dotNodes{
                dot.removeFromParentNode()
            }
        }
        dotNodes.removeAll()
        resultNode.removeFromParentNode()

    }
    @IBAction func undoNode(_ sender: UIBarButtonItem) {
        if !dotNodes.isEmpty{
            dotNodes.last?.removeFromParentNode()
            dotNodes.remove(at: dotNodes.count - 1)
        }
    }
    
}
extension ViewController: ARSCNViewDelegate{
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if dotNodes.count >= 2 {
            for dot in dotNodes{
                dot.removeFromParentNode()
            }
            dotNodes.removeAll()
            resultNode.removeFromParentNode()

        }
        if let touch = touches.first{
            let touchLocation = touch.location(in: sceneView)
            let result = sceneView.hitTest(touchLocation, types: .featurePoint)
            if let hitResult = result.first{
                
                
                let dotGeometry = SCNSphere(radius: 0.005)
                
                let dotMaterial = SCNMaterial()
                dotMaterial.diffuse.contents = UIColor.red
                dotGeometry.materials = [dotMaterial]
                
                let dotNode = SCNNode()
                dotNode.position = SCNVector3(x: hitResult.worldTransform.columns.3.x, y: hitResult.worldTransform.columns.3.y, z: hitResult.worldTransform.columns.3.z)
                
                dotNode.geometry = dotGeometry
                
                sceneView.scene.rootNode.addChildNode(dotNode)
                
                dotNodes.append(dotNode)
                
                if dotNodes.count >= 2 {
                    calculate()
                }
            }
        }
    }
    
    
    func calculate(){
        let firstDot = dotNodes[0]
        let secondDot = dotNodes[1]
        print(firstDot.position)
        print(secondDot.position)
        let x: Float = firstDot.position.x - secondDot.position.x
        let y: Float = firstDot.position.y - secondDot.position.y
        let z: Float = firstDot.position.z - secondDot.position.z
        
        let result = ((x * x) + (y * y) + (z * z)).squareRoot()
        print(result * 100)
        placeResult(forText: "\(result * 100)", atPosition: secondDot.position)
    }
    func placeResult(forText text: String, atPosition position: SCNVector3){
        resultNode.removeFromParentNode()
        let resultText = SCNText(string: text, extrusionDepth: 1.0)
        let resultMaterial = SCNMaterial()
        resultMaterial.diffuse.contents = UIColor.red
        resultText.materials = [resultMaterial]
        resultNode.position = SCNVector3(x: position.x, y: position.y + 0.01, z: position.z)
        resultNode.scale = SCNVector3(x: 0.01, y: 0.01, z: 0.01)
        resultNode.geometry = resultText
        
        sceneView.scene.rootNode.addChildNode(resultNode)
        sceneView.automaticallyUpdatesLighting = true
        
    }
    
}

//
//  ViewController.swift
//  DefendYourself
//
//  Created by Emir Can Marangoz on 23.03.2019.
//  Copyright © 2019 Emir Can Marangoz. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    @IBOutlet weak var waveLabel: UILabel!
    @IBOutlet weak var healthLabel: UILabel!
    @IBOutlet weak var leftLabel: UILabel!
    var health = 3;
    var ballNum = 0;
    var turn = 1;
    @IBAction func onIceBall(_ sender: Any) {
        fireMissile()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.healthLabel.text = String(self.health)
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.scene.physicsWorld.contactDelegate = self
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        startGame(num:self.turn);
        
    }
    func startGame(num:Int){
       
            UIView.animate(withDuration: 1.0, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                self.waveLabel.alpha = 1.0
            }, completion: {
                (finished: Bool) -> Void in
                
                //Once the label is completely invisible, set the text and fade it back in
                self.waveLabel.text = "Wave" + String(num)
                
                // Fade in
                UIView.animate(withDuration: 2.0, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
                    self.waveLabel.alpha = 0.0
                }, completion: nil)
            })
            addTargetNodes(num: 2^num)
            self.ballNum = 2^num
        
        
    }
    func getUserVector() -> (SCNVector3, SCNVector3) { // (direction, position)
        if let frame = self.sceneView.session.currentFrame {
            let mat = SCNMatrix4(frame.camera.transform) // 4x4 transform matrix describing camera in world space
            let dir = SCNVector3(-1 * mat.m31, -1 * mat.m32, -1 * mat.m33) // orientation of camera in world space
            let pos = SCNVector3(mat.m41, mat.m42, mat.m43) // location of camera in world space
            
            return (dir, pos)
        }
        return (SCNVector3(0, 0, -1), SCNVector3(0, 0, -0.2))
    }
    func fireMissile(){
        var node = SCNNode()
        //create node
        node = createMissile()
        
        //get the users position and direction
        let (direction, position) = self.getUserVector()
        node.position = position
        var nodeDirection = SCNVector3()
        
        nodeDirection  = SCNVector3(direction.x*4,direction.y*4,direction.z*4)
        node.physicsBody?.applyForce(nodeDirection, at: SCNVector3(0.1,0,0), asImpulse: true)
            
       
        
        //move node
        node.physicsBody?.applyForce(nodeDirection , asImpulse: true)
        
        //add node to scene
        sceneView.scene.rootNode.addChildNode(node)
    }
    
    //creates nodes
    func createMissile()->SCNNode{
        
        let sphere = SCNSphere(radius: 0.03)
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "ice.jpg")
        sphere.materials = [material]
        let sphereNode = SCNNode(geometry: sphere)
        
        sphereNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        sphereNode.physicsBody?.isAffectedByGravity = false
        
        //these bitmasks used to define "collisions" with other objects
        sphereNode.physicsBody?.categoryBitMask = CollisionCategory.missileCategory.rawValue
        sphereNode.physicsBody?.collisionBitMask = CollisionCategory.targetCategory.rawValue
        return sphereNode
    }
    func addTargetNodes(num: Int){
        let (direction, position) = self.getUserVector()
        for index in 0...num {
            
            
            let sphere = SCNSphere(radius: 1)
            let material = SCNMaterial()
            material.diffuse.contents = UIImage(named: "fire.jpg")
            sphere.materials = [material]
            let sphereNode = SCNNode(geometry: sphere)
            
            
            
            
            sphereNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
            sphereNode.physicsBody?.isAffectedByGravity = false
            //place randomly, within thresholds
            sphereNode.position = SCNVector3(Float.random(in: -10 ... 10),Float.random(in: -4 ... 5),Float.random(in: -40 ... -10))
            
            
            //rotate
            let action : SCNAction = SCNAction.move(to: position, duration: 10)
            let explosed : SCNAction = SCNAction.run { (sphereNode) in
                sphereNode.removeFromParentNode()
                let  explosion = SCNParticleSystem(named: "Explode", inDirectory: nil)
                sphereNode.addParticleSystem(explosion!)
                self.health = self.health - 1
                DispatchQueue.main.async {
                    self.healthLabel.text = String(self.health)
                }
                }
            
             sphereNode.runAction(SCNAction.sequence([action,explosed]))
            
            //for the collision detection
            sphereNode.physicsBody?.categoryBitMask = CollisionCategory.targetCategory.rawValue
            sphereNode.physicsBody?.contactTestBitMask = CollisionCategory.missileCategory.rawValue
            
            //add to scene
            sceneView.scene.rootNode.addChildNode(sphereNode)
        }
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

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        
        
        if contact.nodeA.physicsBody?.categoryBitMask == CollisionCategory.targetCategory.rawValue
            || contact.nodeB.physicsBody?.categoryBitMask == CollisionCategory.targetCategory.rawValue {
            
            
            DispatchQueue.main.async {
                contact.nodeA.removeFromParentNode()
                contact.nodeB.removeFromParentNode()
                if self.ballNum == 0{
                    self.turn += 1
                    self.startGame(num: self.turn)
                }
                else{
                    self.ballNum -= 1
                }
            }
            
            //playSound(sound: "explosion", format: "wav")
            let  explosion = SCNParticleSystem(named: "Explode", inDirectory: nil)
            contact.nodeB.addParticleSystem(explosion!)
        }
    }
}
struct CollisionCategory: OptionSet {
    let rawValue: Int
    static let missileCategory  = CollisionCategory(rawValue: 1 << 0)
    static let targetCategory = CollisionCategory(rawValue: 1 << 1)
    
}

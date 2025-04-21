//
//  DiceSCeneView.swift
//  MonopolyGame
//
//  Created by Mykhailo Dovhyi on 21.04.2025.
//

import SwiftUI
import UIKit
import SceneKit

struct DiceSceneView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> some UIViewController {
        let vc = DiceVC.init()
        vc.view.isUserInteractionEnabled = false
        return vc
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}

class DiceVC: UIViewController, SCNSceneRendererDelegate {
    
    var sceneView: SCNView!
    var diceNodes:[SCNNode] {
        sceneView.scene?.rootNode.childNodes.filter({
            $0.name == "dice"
        }) ?? []
    }

    let cameraHeight: CGFloat = 15.0
    
    func loadDices() {
        let startingPositions: [SCNVector3] = [
            SCNVector3(-0.5, 10, 0),
            SCNVector3( 0.5, 10, 0)
        ]
        for position in startingPositions {
            let cubeGeometry = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0.1)
            cubeGeometry.materials = createDiceMaterials()
            let cubeNode = SCNNode(geometry: cubeGeometry)
            cubeNode.position = position
            
            cubeNode.physicsBody = SCNPhysicsBody.dynamic()
            cubeNode.physicsBody?.mass = 0.9
            cubeNode.physicsBody?.restitution = 1
            cubeNode.physicsBody?.friction = 0.8
            cubeNode.physicsBody?.rollingFriction = 0.8
            cubeNode.physicsBody?.damping = 0.5
            cubeNode.physicsBody?.angularDamping = 0.5
            cubeNode.name = "dice"
            sceneView.scene!.rootNode.addChildNode(cubeNode)

            let randomForceX = Float.random(in: -10...10)
            let randomForceZ = Float.random(in: -10...10)
            cubeNode.physicsBody?.applyForce(SCNVector3(randomForceX, 0, randomForceZ), asImpulse: true)
            
            let randomTorqueX = Float.random(in: -5...5)
            let randomTorqueY = Float.random(in: -5...5)
            let randomTorqueZ = Float.random(in: -5...5)
            cubeNode.physicsBody?.applyTorque(SCNVector4(randomTorqueX, randomTorqueY, randomTorqueZ, 1), asImpulse: true)
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        sceneView = SCNView(frame: self.view.frame)
        sceneView.backgroundColor = .clear
        self.view.addSubview(sceneView)
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sceneView.leadingAnchor.constraint(equalTo: sceneView.superview!.leadingAnchor),
            sceneView.trailingAnchor.constraint(equalTo: sceneView.superview!.trailingAnchor),

            sceneView.topAnchor.constraint(equalTo: sceneView.superview!.topAnchor),
            sceneView.bottomAnchor.constraint(equalTo: sceneView.superview!.bottomAnchor)

        ])
        let scene = SCNScene()
        sceneView.scene = scene
        sceneView.delegate = self
        sceneView.backgroundColor = .clear
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0, Float(cameraHeight), 0)
        cameraNode.eulerAngles = SCNVector3(-Float.pi / 2, 0, 0)
        scene.rootNode.addChildNode(cameraNode)
        
        let floorWidth: CGFloat = 12.0
        let floorHeight: CGFloat = 12.0
        let floorGeometry = SCNPlane(width: floorWidth, height: floorHeight)
        
        floorGeometry.firstMaterial?.diffuse.contents = UIColor.clear
        let floorNode = SCNNode(geometry: floorGeometry)
        floorNode.eulerAngles = SCNVector3(-Float.pi/2, 0, 0)
        floorNode.position = SCNVector3(0, 0, 0)
        floorNode.physicsBody = SCNPhysicsBody.static()
        
        scene.rootNode.addChildNode(floorNode)
        
        addBoundaryWalls(to: scene, floorWidth: floorWidth, floorHeight: floorHeight, wallHeight: cameraHeight)
        
        
        loadDices()
        sceneView.allowsCameraControl = false
        sceneView.showsStatistics = true
        
        
    }
    
    func addBoundaryWalls(to scene: SCNScene, floorWidth: CGFloat, floorHeight: CGFloat, wallHeight: CGFloat) {
        let wallThickness: CGFloat = 0.5
        let wallColor = UIColor.blue.withAlphaComponent(0.1)
        
        let wallY = Float(wallHeight / 2)
        
        let leftWallGeometry = SCNBox(width: wallThickness, height: wallHeight, length: floorHeight, chamferRadius: 0)
        leftWallGeometry.firstMaterial?.diffuse.contents = wallColor
        let leftWallNode = SCNNode(geometry: leftWallGeometry)
        leftWallNode.position = SCNVector3(-Float(floorWidth/2) - Float(wallThickness/2), wallY, 0)
        leftWallNode.physicsBody = SCNPhysicsBody.static()
        scene.rootNode.addChildNode(leftWallNode)
        
        let rightWallGeometry = SCNBox(width: wallThickness, height: wallHeight, length: floorHeight, chamferRadius: 0)
        rightWallGeometry.firstMaterial?.diffuse.contents = wallColor
        let rightWallNode = SCNNode(geometry: rightWallGeometry)
        rightWallNode.position = SCNVector3(Float(floorWidth/2) + Float(wallThickness/2), wallY, 0)
        rightWallNode.physicsBody = SCNPhysicsBody.static()
        scene.rootNode.addChildNode(rightWallNode)
        
        let topWallGeometry = SCNBox(width: floorWidth, height: wallHeight, length: wallThickness, chamferRadius: 0)
        topWallGeometry.firstMaterial?.diffuse.contents = wallColor
        let topWallNode = SCNNode(geometry: topWallGeometry)
        topWallNode.position = SCNVector3(0, wallY, -Float(floorHeight/2) - Float(wallThickness/2))
        topWallNode.physicsBody = SCNPhysicsBody.static()
        scene.rootNode.addChildNode(topWallNode)
        
        let bottomWallGeometry = SCNBox(width: floorWidth, height: wallHeight, length: wallThickness, chamferRadius: 0)
        bottomWallGeometry.firstMaterial?.diffuse.contents = wallColor
        let bottomWallNode = SCNNode(geometry: bottomWallGeometry)
        bottomWallNode.position = SCNVector3(0, wallY, Float(floorHeight/2) + Float(wallThickness/2))
        bottomWallNode.physicsBody = SCNPhysicsBody.static()
        scene.rootNode.addChildNode(bottomWallNode)
    }
    
    func imageWithText(_ text: String, size: CGSize = CGSize(width: 256, height: 256)) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        defer { UIGraphicsEndImageContext() }
        
        UIColor.red.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: size.height/2),
            .foregroundColor: UIColor.white,
            .paragraphStyle: paragraphStyle
        ]
        
        let textHeight = size.height/2
        let textRect = CGRect(x: 0, y: (size.height - textHeight) / 2, width: size.width, height: textHeight)
        (text as NSString).draw(in: textRect, withAttributes: attributes)
        
        return UIGraphicsGetImageFromCurrentImageContext()!
    }

    func createDiceMaterials() -> [SCNMaterial] {
        var materials = [SCNMaterial]()
        for i in 1...6 {
            let material = SCNMaterial()
            material.diffuse.contents = imageWithText("\(i)")
            materials.append(material)
        }
        return materials
    }
    
    
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
    func isDiceAtRest(_ dice: SCNNode, threshold: Float = 0.1) -> Bool {
        if let velocity = dice.physicsBody?.velocity {
            let mag = sqrt(velocity.x * velocity.x + velocity.y * velocity.y + velocity.z * velocity.z)
            return mag < threshold
        }
        return false
    }
    func renderer(_ renderer: any SCNSceneRenderer, updateAtTime time: TimeInterval) {
        print(diceNodes.count, " erfwdas")
        for dice in diceNodes {
            if let body = dice.physicsBody, isDiceAtRest(dice){
                
                if let topFaceIndex = upwardFaceIndex(for: dice) {
                    let diceNumber = topFaceIndex + 1
                    dice.name = "diceOK"
                    print("Dice has come to rest with \(diceNumber) facing up")
                    if self.diceNodes.isEmpty {
                        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: { [weak self] in
                            self?.sceneView.scene?.rootNode.childNodes.forEach { node in
                                if node.name?.contains("dice") ?? false {
                                    node.removeFromParentNode()
                                }
                            }
                            self?.loadDices()
                        })
                    }
                }
            }
        }
    }
    
    func upwardFaceIndex(for dice: SCNNode) -> Int? {
        let faceNormals: [SCNVector3] = [
            SCNVector3(0, 0, -1),
            SCNVector3(1, 0, 0),
            SCNVector3(0, 0, 1),
            SCNVector3(-1, 0, 0),
            SCNVector3(0, 1, 0),
            SCNVector3(0, -1, 0)
        ]
        
        let worldUp = SCNVector3(0, 1, 0)
        let transform = dice.presentation.worldTransform
        
        var bestIndex: Int?
        var highestDot: Float = -Float.infinity
        
        for (index, normal) in faceNormals.enumerated() {
            let transformedNormal = transformDirection(normal, with: transform)
            let dotValue = dotProduct(transformedNormal, worldUp)
            print("Dice: \(dice), Face \(index) dot: \(dotValue)")
            if dotValue > highestDot {
                highestDot = dotValue
                bestIndex = index
            }
        }
//        if bestIndex == 3 {
//            bestIndex = 1
//        } else if bestIndex == 1 {
//            bestIndex = 3
//        }
        return bestIndex
    }
    func transformDirection(_ vector: SCNVector3, with transform: SCNMatrix4) -> SCNVector3 {
            let x = transform.m11 * vector.x + transform.m21 * vector.y + transform.m31 * vector.z
            let y = transform.m12 * vector.x + transform.m22 * vector.y + transform.m32 * vector.z
            let z = transform.m13 * vector.x + transform.m23 * vector.y + transform.m33 * vector.z
            return SCNVector3(x, y, z)
        }
        
        func dotProduct(_ v1: SCNVector3, _ v2: SCNVector3) -> Float {
            return v1.x * v2.x + v1.y * v2.y + v1.z * v2.z
        }
}

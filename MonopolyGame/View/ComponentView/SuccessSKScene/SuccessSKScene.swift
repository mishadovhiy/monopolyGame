//
//  SuccessSKScene.swift
//  MonopolyGame
//
//  Created by Misha Dovhiy on 17.01.2023.
//

import SpriteKit
import GameplayKit
import UIKit

import SwiftUI

struct SuccessSceneView: UIViewRepresentable {
    let viewSize:CGSize
    func makeUIView(context: Context) -> some SKView {
        let skView = SKView()
        skView.backgroundColor = .clear
        let scene = SuccessSKScene(size: viewSize)
        scene.backgroundColor = .clear
                scene.scaleMode = .resizeFill
                skView.presentScene(scene)
                
                return skView
    }
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}

class SuccessSKScene: SKScene {

    var scsType:ObjectsType = .coloredConfety
    
    static var shared:SuccessSKScene?
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        SuccessSKScene.shared = self
        physicsWorld.contactDelegate = self
        physicsWorld.speed = 0.23
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            self.setupLvl()
        })
    }

    static func create(view:UIView, type:ObjectsType = .coloredConfety) {
        if let newView = view as! SKView? {
            if let scene = SKScene(fileNamed: "SuccessSKScene") as? SuccessSKScene {
                scene.scaleMode = .aspectFill
                scene.scsType = type
                scene.backgroundColor = .clear
                newView.presentScene(scene)
            }
            newView.ignoresSiblingOrder = true
            newView.showsFPS = true
            newView.showsNodeCount = false
        }
    }
    var mapNode: SKTileMapNode?
    func setupLvl() {
        self.mapNode = childNode(withName: "SCSTileNode") as? SKTileMapNode
        addManyNodes()
        physicsBody = SKPhysicsBody(edgeLoopFrom: .init(x: 0, y: size.height / -2, width: self.size.width, height: self.size.height * 2))
        
        physicsBody?.categoryBitMask = GameGlobals.PhysicsCategory.edge
        physicsBody?.contactTestBitMask = GameGlobals.PhysicsCategory.bird | GameGlobals.PhysicsCategory.block
        physicsBody?.collisionBitMask = GameGlobals.PhysicsCategory.all
    }

    var addedCount = 0
    func addManyNodes() {
      /*  if addedCount <= 40 {
            self.addSCSNodes()
            addedCount += 1
            DispatchQueue.main.asyncAfter(deadline: .now() + .microseconds(self.addedCount <= 10 ? 900000 : 900000), execute: {
                if self.addedCount <= 10 {
                    for _ in 0..<2 {
                        self.addManyNodes()
                    }
                } else {
                    self.addManyNodes()
                }
                
            })
        }*/
        
        for _ in 0..<(addedCount <= 10 ? 10 : 3) {
            self.addSCSNodes()
        }
        addedCount += 1
        DispatchQueue.main.asyncAfter(deadline: .now() + .microseconds(1000000), execute: {
            self.addManyNodes()
        })
        
        /*for _ in 0..<count {
            for _ in 0..<Int(horizontalCount) {
                self.addSCSNodes(position: height)
            }
            height -= step
        }*/

    }
    
    func addSCSNodes(position:CGFloat? = nil) {
        let scsNodes:[SuccessNode] = scsType == .coloredConfety ? [
            .init(type: .Oval), .init(type: .YellowLine), .init(type: .RedLine), .init(type: .Oval), .init(type: .Oval), .init(type: .Oval)
        ] : [.init(type: .greenTriggles)]
        guard let scsNode = scsNodes.randomElement() else { return }
        scsNode.physicsBody = SKPhysicsBody(rectangleOf: scsNode.size)
        scsNode.physicsBody?.categoryBitMask = GameGlobals.PhysicsCategory.bird
        scsNode.physicsBody?.contactTestBitMask = GameGlobals.PhysicsCategory.all
        scsNode.physicsBody?.collisionBitMask = GameGlobals.PhysicsCategory.block | GameGlobals.PhysicsCategory.edge

        scsNode.position = .init(x: .random(in: 0..<size.width), y: size.height + CGFloat.random(in: 20..<500))
        scsNode.physicsBody?.isDynamic = true
        
        addChild(scsNode)

        
    }

    
    
    enum ObjectsType {
    case coloredConfety
        case greenTriaggles
    }
}

extension SuccessSKScene:SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        let mask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        switch mask {
        case GameGlobals.PhysicsCategory.bird | GameGlobals.PhysicsCategory.edge:
            if let node = contact.bodyB.node as? SuccessNode {
                node.remove()
            } else if let node = contact.bodyA.node as? SuccessNode {
                node.remove()
            }
        default:
            break
        }
    }

}


struct GameGlobals {
    struct ZPosition {
        static let background: CGFloat = 0
        static let obstacles: CGFloat = 1
        static let bird: CGFloat = 2
        static let hudBackground: CGFloat = 10
        static let hudLabel: CGFloat = 11
    }

    struct PhysicsCategory {
        static let none:UInt32 = 0
        static let all:UInt32 = UInt32.max
        static let edge:UInt32 = 0x1
        static let bird:UInt32 = 0x1 << 1
        static let block:UInt32 = 0x1 << 2

    }
}

//
//  BubbleNode.swift
//  TravelApp
//
//  Created by Conner Christianson on 3/20/17.
//  Copyright © 2017 Scott Franklin. All rights reserved.
//

import Foundation

import SIFloatingCollection
import UIKit
import SpriteKit

class BubbleNode: SIFloatingNode {
    var labelNode = SKLabelNode(fontNamed: "Avenir")
    let colors: [String:SKColor] = ["Night Clubs" : SKColor.init(red: 0/255.0, green: 51/255.0, blue: 102/255.0,alpha: 1),
                                    "Museums" : SKColor.init(red: 215/255.0, green: 158/255.0, blue: 0/255.0, alpha: 1),
                                    "Art Galleries" : SKColor.init(red: 202/255.0, green: 120/255.0, blue: 120/255.0, alpha: 1),
                                    "Casinos" : SKColor.init(red: 171/255.0, green: 143/255.0, blue: 193/255.0, alpha: 1),
                                    "Parks" : SKColor.init(red: 181/255.0, green: 230/255.0, blue: 162/255.0, alpha: 1),
                                    "Aquariums" : SKColor.init(red: 70/255.0, green: 170/255.0, blue: 255/255.0, alpha: 1),
                                    "Movie Theaters" : SKColor.black,
                                    "Food" : SKColor.init(red: 255/255.0, green: 130/255.0, blue: 0/255.0, alpha: 1),
                                    "Bars" : SKColor.init(red: 36/255.0, green: 100/255.0, blue: 241/255.0, alpha: 1)]
    
    class func instantiate() -> BubbleNode {
        let node = BubbleNode(circleOfRadius: 45)
        configureNode(node)
        return node
    }
    
    class func configureNode(_ node: BubbleNode) {
        let boundingBox = node.path?.boundingBox;
        let radius = (boundingBox?.size.width)! / 2.0;
        node.physicsBody = SKPhysicsBody(circleOfRadius: radius + 1.5)
        node.fillColor = SKColor.gray
        //let image = #imageLiteral(resourceName: "spherelight")
        //node.fillTexture = SKTexture.init(image: image)
        node.strokeColor = node.fillColor
        
        node.labelNode.text = ""
        node.labelNode.position = CGPoint.zero
        node.labelNode.fontColor = SKColor.white
        node.labelNode.fontSize = 12
        node.labelNode.isUserInteractionEnabled = false
        node.labelNode.verticalAlignmentMode = .center
        node.labelNode.horizontalAlignmentMode = .center
        node.addChild(node.labelNode)
    }
    
    public func getText(node: BubbleNode) -> String {
        return node.labelNode.text!
    }
    
    public func changeText(node: BubbleNode, newText: String){
        node.labelNode.text = newText;
    }
    
    override func selectingAnimation(node: SIFloatingNode) -> SKAction? {
        let bubble = node as? BubbleNode
        node.fillColor = colors[getText(node: bubble!)]!
        node.strokeColor = node.fillColor
        return SKAction.scale(to: 1.3, duration: 0.2)
    }
    
    override func normalizeAnimation(node: SIFloatingNode) -> SKAction? {
        let bubble = node as? BubbleNode
        bubble?.fillColor = SKColor.gray
        node.strokeColor = node.fillColor
        return SKAction.scale(to: 1, duration: 0.2)
    }
    
    override func removeAnimation() -> SKAction? {
        return SKAction.fadeOut(withDuration: 0.2)
    }
    
    override func removingAnimation() -> SKAction {
        let pulseUp = SKAction.scale(to: xScale + 0.13, duration: 0)
        let pulseDown = SKAction.scale(to: xScale, duration: 0.3)
        let pulse = SKAction.sequence([pulseUp, pulseDown])
        let repeatPulse = SKAction.repeatForever(pulse)
        return repeatPulse
    }
    
    func `throw`(to point: CGPoint, completion block: @escaping (() -> Void)) {
        removeAllActions()
        let movingXAction = SKAction.moveTo(x: point.x, duration: 0.2)
        let movingYAction = SKAction.moveTo(y: point.y, duration: 0.4)
        let resize = SKAction.scale(to: 0.3, duration: 0.4)
        let throwAction = SKAction.group([movingXAction, movingYAction, resize])
        run(throwAction, completion: block)
    }
}

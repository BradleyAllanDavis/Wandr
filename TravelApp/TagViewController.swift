//
//  TagViewController.swift
//  TravelApp
//
//  Created by Macbook on 3/8/17.
//  Copyright © 2017 Scott Franklin. All rights reserved.
//

import UIKit
import SpriteKit

class TagViewController: UIViewController {
    fileprivate var skView: SKView!
    fileprivate var floatingCollectionScene: BubblesScene!
    let types = ["Parks", "Night Clubs", "Movie Theaters", "Casinos", "Bars", "Art Galleries", "Aquariums", "Museums", "Food"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        skView = SKView(frame: UIScreen.main.bounds)
        skView.backgroundColor = SKColor.white
        view.addSubview(skView)
        
        floatingCollectionScene = BubblesScene(size: skView.bounds.size)
        let navBarHeight = navigationController!.navigationBar.frame.height
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        floatingCollectionScene.topOffset = navBarHeight + statusBarHeight
        skView.presentScene(floatingCollectionScene)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(commitSelection)
        )
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addBubble)
        )
        
        for index in 0..<types.count {
            addBubble(index: index)
        }
    }
    
    func addBubble(index: Int) {
        let newNode = BubbleNode.instantiate()
        newNode.changeText(node: newNode, newText: types[index])
        floatingCollectionScene.addChild(newNode)
    }
    
    func commitSelection() {
        floatingCollectionScene.performCommitSelectionAnimation()
    }
}

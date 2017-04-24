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
    var types = ["Parks", "Night Clubs", "Movie Theaters", "Casinos", "Bars", "Art Galleries", "Aquariums", "Museums", "Food"]
    var availableTypes = [String: String]()
    var tagPreferences = [String: Bool]()
    var bubbles: [BubbleNode] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let plistManager = Plist(name: "availableTags")
        availableTypes = plistManager?.getValuesInPlistFile() as! Dictionary<String, String>
        tagPreferences = PlaceStore.shared.tagPreferences
        skView = SKView(frame: UIScreen.main.bounds)
        skView.backgroundColor = SKColor.white
        view.addSubview(skView)
        
        floatingCollectionScene = BubblesScene(size: skView.bounds.size)
        let navBarHeight = navigationController!.navigationBar.frame.height
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        floatingCollectionScene.topOffset = navBarHeight + statusBarHeight
        
        skView.presentScene(floatingCollectionScene)
        
        // TODO: Change to a more user-friendly button?
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(commitSelection)
        )
        
        for index in 0..<types.count {
            addBubble(index: index)
        }
    }
    
    func addBubble(index: Int) {
        let newNode = BubbleNode.instantiate()
        newNode.changeText(node: newNode, newText: types[index])
        let typeString = types[index]
        
        if availableTypes[typeString] != nil && tagPreferences[availableTypes[typeString]!]! {
            newNode.state = .selected
        }
        
        bubbles.append(newNode)
        floatingCollectionScene.addChild(newNode)
    }
    
    
    func commitSelection() {
        tagPreferences = floatingCollectionScene.performCommitSelectionAnimation()
        PlaceStore.shared.setTags(tags: tagPreferences)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: {
            if let vc =  self.presentingViewController as? MapViewController {
//                vc.tagPreferences = self.tagPreferences
                vc.redoSearchInArea()
                self.dismiss(animated: true, completion: nil)
            } else {
                self.performSegue(withIdentifier: "toMap", sender: nil)
            }
        })
    }
}

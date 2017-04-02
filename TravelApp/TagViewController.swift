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
    var tagPreferences = ["restaurant": false, "museum": false, "aquarium": false, "art_gallery": false, "bar": false, "casino": false, "movie_theater": false, "night_club": false, "park": false]
    var bubbles: [BubbleNode] = []
    
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
        bubbles.append(newNode)
        floatingCollectionScene.addChild(newNode)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMap" {
            if let nextVC = segue.destination as? MapViewController {
                nextVC.tagPreferences = tagPreferences
            }
        }
    }
    
    func commitSelection() {
        tagPreferences = floatingCollectionScene.performCommitSelectionAnimation()
        performSegue(withIdentifier: "toMap", sender: nil)
    }
}

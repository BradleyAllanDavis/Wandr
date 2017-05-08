//
//  TagViewController.swift
//  TravelApp
//
//  Created by Macbook on 3/8/17.
//  Copyright © 2017 Scott Franklin. All rights reserved.
//

import UIKit
import SpriteKit
import SIFloatingCollection
import FBSDKLoginKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class TagViewController: UIViewController {
    fileprivate var skView: SKView!
    fileprivate var floatingCollectionScene: BubblesScene!
    let types = ["Parks", "Night Clubs", "Movie Theaters", "Casinos", "Bars", "Art Galleries", "Aquariums", "Museums", "Food"]
    var tagPreferences = ["restaurant": false, "museum": false, "aquarium": false, "art_gallery": false, "bar": false, "casino": false, "movie_theater": false, "night_club": false, "park": false]
    var bubbles: [BubbleNode] = []
    var availableTypes = [String: String]()
    var alertController: UIAlertController?
    var alertTimer: Timer?
    var remainingTime = 0
    var baseMessage: String?
    var ref: FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let plistManager = Plist(name: "availableTags")
        availableTypes = plistManager?.getValuesInPlistFile() as! Dictionary<String, String>
        tagPreferences = PlaceStore.shared.tagPreferences
        for tag in tagPreferences {
            if tag.value == true {
                SIFloatingNode.count += 1
            }
        }
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
        
        if availableTypes[typeString] != nil &&
            tagPreferences[availableTypes[typeString]!] != nil &&
            tagPreferences[availableTypes[typeString]!]! {
            newNode.state = .selected
        }
        
        bubbles.append(newNode)
        floatingCollectionScene.addChild(newNode)
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "toMap" {
//            if segue.destination is MapViewController {
//                PlaceStore.shared.setTags(tags: tagPreferences)
//            }
//        }
//    }
    
    func commitSelection() {
        var atLeastOnePreferenceSet = false
        for bubble in bubbles {
            let node = bubble as SIFloatingNode
            if node.state == .selected {
                atLeastOnePreferenceSet = true
            }
        }
        
        if !atLeastOnePreferenceSet {
            showAlertMsg("Oops!", message: "Choose at least one preference", time: 3)
            return
        }
        
        tagPreferences = floatingCollectionScene.performCommitSelectionAnimation()
        PlaceStore.shared.setTags(tags: tagPreferences)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: {
            SIFloatingNode.count = 0
            if let vc =  self.presentingViewController as? MapViewController {
                vc.redoSearchInArea()
                self.dismiss(animated: true, completion: nil)
            } else {
                self.performSegue(withIdentifier: "toMap", sender: nil)
            }
        })
    }
    
    // Alert message popup methods
    
    func showAlertMsg(_ title: String, message: String, time: Int) {
        
        guard (self.alertController == nil) else {
            print("Alert already displayed")
            return
        }
        
        self.baseMessage = message
        self.remainingTime = time
        
        self.alertController = UIAlertController(title: title, message: self.baseMessage, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            print("Alert was cancelled")
            self.alertController=nil;
            self.alertTimer?.invalidate()
            self.alertTimer=nil
        }
        
        self.alertController!.addAction(cancelAction)
        
        self.alertTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.countDown), userInfo: nil, repeats: true)
        
        self.present(self.alertController!, animated: true, completion: nil)     
    }
    
    func countDown() {
        
        self.remainingTime -= 1
        if (self.remainingTime < 0) {
            self.alertTimer?.invalidate()
            self.alertTimer = nil
            self.alertController!.dismiss(animated: true, completion: {
                self.alertController = nil
            })
        } else {
            self.alertController!.message = self.baseMessage
        }
        
    }
}

extension TagViewController: FBSDKLoginButtonDelegate {
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        guard let current = FBSDKAccessToken.current() else {
            return
        }
        
        let credential = FIRFacebookAuthProvider.credential(withAccessToken: current.tokenString)
        
        ref = FIRDatabase.database().reference()
        
        FIRAuth.auth()?.signIn(with:credential) { (user, error) in
            if error != nil {
                print("something went wrong")
                return
            }
            let userId = (FIRAuth.auth()?.currentUser?.uid)!
            self.ref.child("Login").observeSingleEvent(of: .value, with: {(snapshot) in
                
                if !snapshot.hasChild(userId) {
                    self.ref.child("Login").child(userId).child("recurring").setValue("True")
                    
                }
            })
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Welcome", bundle: nil)
        let vc: UIPageViewController = storyboard.instantiateViewController(withIdentifier: "PageViewController") as! OnboardPageViewController
        self.present(vc, animated: true, completion: nil)
        return
    }
}

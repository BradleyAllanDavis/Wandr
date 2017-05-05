//
//  WelcomeButtonView.swift
//  TravelApp
//
//  Created by Scott Franklin on 4/23/17.
//  Copyright © 2017 Scott Franklin. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class WelcomeButtonViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    var loginButtonView: FBSDKLoginButton = FBSDKLoginButton()
    var ref: FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view, typically from a nib.
    }
    
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
                
                if snapshot.hasChild(userId) {
                    let storyboard: UIStoryboard = UIStoryboard(name: "Map", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "Map") as! MapViewController
                    self.present(vc, animated: true, completion: nil)
                }
                else {
                    self.ref.child("Login").child(userId).child("recurring").setValue("True")
                    let storyboard: UIStoryboard = UIStoryboard(name: "Tag", bundle: nil)
                    let vc: UINavigationController = storyboard.instantiateViewController(withIdentifier: "TagNavigationView") as! UINavigationController
                    self.present(vc, animated: true, completion: nil)
                }
                
                
            })
        }
    }

    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        return
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

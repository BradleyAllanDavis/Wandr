//
//  WelcomeButtonView.swift
//  TravelApp
//
//  Created by Scott Franklin on 4/23/17.
//  Copyright © 2017 Scott Franklin. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class WelcomeButtonViewController: UIViewController {
    
    var loginButtonView: FBSDKLoginButton = FBSDKLoginButton()
    
    @IBAction func facebookLogin(_ sender: Any) {
        let login = FBSDKLoginManager()
        login.loginBehavior = FBSDKLoginBehavior.systemAccount
        login.logIn(withReadPermissions: ["public_profile", "email"], from: self, handler: {(result, error) in
            if error != nil {
                print("Error :  ")
            }
            else if (result?.isCancelled)! {
                
            }
            else {
                FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "first_name, last_name, picture.type(large), email, name, id, gender"]).start(completionHandler: {(connection, result, error) -> Void in
                    if error != nil{
                        print("Error : ")
                    }else{
                        print("userInfo is \(String(describing: result)))")
                        //save user info data
                        //present next view
                        let vc = MapViewController()
                        self.present(vc, animated: true, completion: nil)
                    }
                })
            }
            
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //loginButtonView.frame = CGRect(x: 20, y: 20, width: 20, height: 20)
        //loginButtonView.center = self.view.center
        //self.view.addSubview(loginButtonView)
        //loginButtonView.readPermissions = ["public_profile", "email", "user_friends","user_birthday"]
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

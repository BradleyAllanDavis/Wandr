//
//  WelcomeViewController.swift
//  TravelApp
//
//  Created by Macbook on 4/23/17.
//  Copyright © 2017 Scott Franklin. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import SwiftyGif

class TagTutViewController: UIViewController {

    @IBOutlet weak var tagGif: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let gifManager = SwiftyGifManager(memoryLimit: 20)
        let gif = UIImage(gifName: "tagTut.gif")
        self.tagGif.setGifImage(gif, manager: gifManager)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

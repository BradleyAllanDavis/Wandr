//
//  CartTutViewController.swift
//  TravelApp
//
//  Created by Macbook on 4/23/17.
//  Copyright © 2017 Scott Franklin. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import SwiftyGif

class CartTutViewController: UIViewController {
    
    @IBOutlet weak var cartGif: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let gifManager = SwiftyGifManager(memoryLimit: 20)
        let gif = UIImage(gifName: "cartTut.gif")
        self.cartGif.setGifImage(gif, manager: gifManager)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

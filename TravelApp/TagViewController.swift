//
//  TagViewController.swift
//  TravelApp
//
//  Created by Macbook on 3/8/17.
//  Copyright © 2017 Scott Franklin. All rights reserved.
//

import UIKit

class TagViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // txt file is saved to our app's documents directory
    let file = "tagPreferences.txt"
    let text = "food:80%\nmuseums:40%\ntheaters:20%"
    
}

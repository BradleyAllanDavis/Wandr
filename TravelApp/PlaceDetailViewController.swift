//
//  PlaceDetailViewController.swift
//  TravelApp
//
//  Created by Macbook on 4/11/17.
//  Copyright © 2017 Scott Franklin. All rights reserved.
//

import UIKit

class PlaceDetailViewController: UIViewController {
    
    
    @IBOutlet weak var placeTitleLabel: UILabel!
    var placeTitle: String?
    var placeDescription: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        placeTitleLabel.text = placeTitle!
        //print(placeTitle!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

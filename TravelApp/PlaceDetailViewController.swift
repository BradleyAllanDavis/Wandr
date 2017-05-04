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
    
    var placeTitle: String = "default"
    var placeDescription: String?
    var placeID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print(self.placeTitle)
        
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        blur.frame = self.view.bounds
        self.view.addSubview(blur)
        self.view.sendSubview(toBack: blur)
        
//        self.placeTitleLabel.text = self.placeTitle
        
//        if let place = PlaceStore.shared.getPlace(for: self.placeID!) {
//            placeTitleLabel.text = place["name"] as? String
//        }
        
//        let place = PlaceStore.shared.getPlace(for: self.placeID!)
//        placeTitleLabel.text = place!["name"] as? String
//        place["place_id"] as! String
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

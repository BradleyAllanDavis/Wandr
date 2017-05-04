//
//  CardContentViewController.swift
//  TravelApp
//
//  Created by Jason Cheng on 5/4/17.
//  Copyright © 2017 Scott Franklin. All rights reserved.
//

import Foundation
import UIKit
import Cosmos

class CardContentViewController: UIViewController {
    
    @IBOutlet var label: UILabel!
    @IBOutlet var vicinity: UILabel!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var descrip: UITextView!
    @IBOutlet var starView: UIView!
    var image: UIImage?
    var placeId: String?
    var starLabel: CosmosView?
    var type: String?
    
    let types = ["park":"Parks", "night_club":"Night Clubs", "movie_theater":"Movie Theaters", "casino":"Casinos", "bar":"Bars", "art_gallery":"Art Galleries", "aquarium":"Aquariums", "museum":"Museums", "restaurant":"Food"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Shadow
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.25
        view.layer.shadowOffset = CGSize(width: 0, height: 1.5)
        view.layer.shadowRadius = 4.0
        view.layer.shouldRasterize = true
        view.layer.rasterizationScale = UIScreen.main.scale
        
        // Corner Radius
        view.layer.cornerRadius = 10.0
        starView.layer.cornerRadius = 10.0
        
        // Glow effect for light background
        label.layer.shadowColor = UIColor.darkGray.cgColor
        label.layer.shadowRadius = 8.0
        label.layer.shadowOpacity = 0.7
        label.layer.shadowOffset = CGSize(width: 0, height: 0)
        vicinity.layer.shadowColor = UIColor.darkGray.cgColor
        vicinity.layer.shadowRadius = 8.0
        vicinity.layer.shadowOpacity = 0.7
        vicinity.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        // Text description scroll to top
        descrip.isScrollEnabled = false
        
        // Star rating
        starLabel = CosmosView(frame: CGRect(x: starView.layer.bounds.midX, y: starView.layer.bounds.midY, width: 100, height: 30))
        starLabel?.center = CGPoint(x: starView.layer.bounds.midX, y: starView.layer.bounds.midY)
        starLabel?.settings.fillMode = .precise
        starLabel?.backgroundColor = .none
        starLabel?.settings.updateOnTouch = false
        starView.addSubview(starLabel!)
        
        

    }
    
    override func viewDidAppear(_ animated: Bool) {
        let placeData = PlaceStore.shared.getPlace(for: placeId!)
        
        let placeDataTypes = placeData?["types"] as! [String]
        if let type = types[placeDataTypes[0]] {
            descrip.text = "Based on your interest in \(type)"
        }
        descrip.isScrollEnabled = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

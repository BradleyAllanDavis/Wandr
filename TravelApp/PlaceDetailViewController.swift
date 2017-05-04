//
//  PlaceDetailViewController.swift
//  TravelApp
//
//  Created by Macbook on 4/11/17.
//  Copyright © 2017 Scott Franklin. All rights reserved.
//

import UIKit
import Cosmos

class PlaceDetailViewController: UIViewController {
    
    @IBOutlet weak var vicinity: UILabel!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var placeTitleLabel: UILabel!
    var starLabel: CosmosView?
    
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
        
        if let place = PlaceStore.shared.getPlace(for: self.placeID!) {
            self.placeTitleLabel.text = place["name"] as? String
            
//            starLabel = CosmosView(frame: CGRect(x: self.view.center.x, y: 90, width: 100, height: 30))
//            starLabel?.rating = place["rating"] as! Double
//            starLabel?.center = CGPoint(x: self.view.center.x, y: 90)
//            starLabel?.settings.fillMode = .precise
//            starLabel?.backgroundColor = .none
//            starLabel?.settings.updateOnTouch = false
//            self.view.addSubview(starLabel!)
            
            let photo = PlaceStore.shared.getPhoto(for: place["place_id"] as! String)
            self.photo.image = photo.image
            
            self.vicinity?.text = place["vicinity"] as? String
        }
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.dismissVC))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)
    }
    
    func dismissVC() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

//
//  PlaceDetailViewController.swift
//  TravelApp
//
//  Created by Macbook on 4/11/17.
//  Copyright © 2017 Scott Franklin. All rights reserved.
//

import UIKit
import Cosmos
import GooglePlaces

class PlaceDetailViewController: UIViewController {
    
    @IBOutlet weak var vicinity: UILabel!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var placeTitleLabel: UILabel!
    @IBAction func search(_ sender: Any) {
        searchForDetails()
    }
    var starLabel: CosmosView?
    var place: GMSPlace?
    
    var placeTitle: String = "default"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print(self.placeTitle)
        
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        blur.frame = self.view.bounds
        self.view.addSubview(blur)
        self.view.sendSubview(toBack: blur)
        
        
        self.placeTitleLabel.text = place?.name
            
//            starLabel = CosmosView(frame: CGRect(x: self.view.center.x, y: 90, width: 100, height: 30))
//            starLabel?.rating = place["rating"] as! Double
//            starLabel?.center = CGPoint(x: self.view.center.x, y: 90)
//            starLabel?.settings.fillMode = .precise
//            starLabel?.backgroundColor = .none
//            starLabel?.settings.updateOnTouch = false
//            self.view.addSubview(starLabel!)
            
        let photo = PlaceStore.shared.getPhoto(for: (place?.placeID)!)
        self.photo.image = photo.image
        
        self.vicinity?.text = place?.formattedAddress
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.dismissVC))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)
    }
    
    func searchForDetails() {
        var urlString: String = "http://www.google.com/"
        var stringBuilder : String = "#q="
        
        let placeId = self.place?.placeID
        let place = PlaceStore.shared.getPlace(for: placeId!)!
        let placeTitle = place["name"]
        let titleArr: [String] = placeTitle!.components(separatedBy: " ")
        
        for i in 0..<titleArr.count {
            stringBuilder.append(titleArr[i])
            if(i != titleArr.count-1){
                stringBuilder.append("+")
            }
        }
        
        urlString += stringBuilder
        
        print(urlString)
        let url = URL(string: urlString)
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        } else {
            // Fallback on earlier versions
            UIApplication.shared.openURL(url!)
        }
    }
    
    func dismissVC() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

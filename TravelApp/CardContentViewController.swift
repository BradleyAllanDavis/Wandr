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
import WebKit

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
    var webView:WKWebView!
    
    let typeTexts = ["park":"Parks", "night_club":"Night Clubs", "movie_theater":"Movie Theaters", "casino":"Casinos", "bar":"Bars", "art_gallery":"Art Galleries", "aquarium":"Aquariums", "museum":"Museums", "restaurant":"Food"]
    
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
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(sender:)))
            
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(tapGesture)
    }
    
    func handleTap(sender: UITapGestureRecognizer) {
        var urlString: String = "http://www.google.com/"
        var stringBuilder : String = "#q="

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
    
    override func viewDidAppear(_ animated: Bool) {
        if type != nil {
            if let typeText = typeTexts[type!] {
                descrip.text = "Based on your interest in \(typeText)"
            }
        }
        descrip.isScrollEnabled = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

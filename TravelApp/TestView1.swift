//
//  TestView2.swift
//  TravelApp
//
//  Created by Jason Cheng on 4/30/17.
//  Copyright © 2017 Scott Franklin. All rights reserved.
//

import UIKit
import Cosmos

class TestView1: UIView {
    
    var label: UILabel?
    var image: UIImage?
    var vicinity: UILabel?
    var imageView: UIImageView?
    var placeId: String?
    var descrip: UITextView?
    var starLabel: CosmosView?
    var type: String?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        // Shadow
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.25
        layer.shadowOffset = CGSize(width: 0, height: 1.5)
        layer.shadowRadius = 4.0
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        
        // Corner Radius
        layer.cornerRadius = 10.0;
        
        // Place title (label)
        label = UILabel(frame: CGRect(x: 0, y: 280, width: self.frame.width, height: 30))
        label?.adjustsFontSizeToFitWidth = true
        label?.textAlignment = .center
        label?.font = label?.font.withSize(22.0)
        label?.textColor = UIColor.white
        self.addSubview(label!)
        
        // Detail layer
        let rect = CGRect(x: 5, y: self.layer.bounds.midY+100, width: self.layer.bounds.width-10, height: self.layer.bounds.maxY-(self.layer.bounds.midY+105))
        let detailView = UIView(frame: rect)
        detailView.layer.cornerRadius = 10.0
        detailView.layer.masksToBounds = true
        detailView.backgroundColor = UIColor.white
        self.addSubview(detailView)
        
        // Star rating
        starLabel = CosmosView(frame: CGRect(x: self.layer.bounds.midX, y: self.layer.bounds.maxY-80, width: 100, height: 30))
        starLabel?.center = CGPoint(x: self.layer.bounds.midX, y: self.layer.bounds.maxY-80)
        starLabel?.settings.fillMode = .precise
        starLabel?.backgroundColor = .none
        starLabel?.settings.updateOnTouch = false
        self.addSubview(starLabel!)
        
        // Image
        let image = #imageLiteral(resourceName: "Placeholder_location.png")
        imageView = UIImageView(image: image)
        imageView?.contentMode = .scaleAspectFill
        imageView?.frame = CGRect(x: self.center.x - 100, y: self.center.y - 200, width: 200, height: 200)
        self.addSubview(imageView!)
        
        // Vicinity
        vicinity = UILabel(frame: CGRect(x: 15, y: self.center.y + 20, width: self.frame.width - 30, height: 20))
        vicinity?.adjustsFontSizeToFitWidth = true
        vicinity?.textAlignment = .center
        vicinity?.textColor = UIColor.white
        self.addSubview(vicinity!)
    }
}

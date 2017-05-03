//
//  TestView2.swift
//  TravelApp
//
//  Created by Jason Cheng on 4/30/17.
//  Copyright © 2017 Scott Franklin. All rights reserved.
//

import UIKit

class TestView1: UIView {
    
    var label: UILabel?
    var image: UIImage?
    var descrip: UITextView?
    var imageView: UIImageView?
    var placeId: String?
    
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
        label = UILabel(frame: CGRect(x: 0, y: 30, width: self.frame.width, height: 30))
        label?.adjustsFontSizeToFitWidth = true
        label?.textAlignment = .center
        self.addSubview(label!)
        
        // Image
        let image = #imageLiteral(resourceName: "Placeholder_location.png")
        imageView = UIImageView(image: image)
        imageView?.contentMode = .scaleAspectFill
        imageView?.frame = CGRect(x: self.center.x - 100, y: self.center.y - 220, width: 200, height: 200)
        self.addSubview(imageView!)
    }
}

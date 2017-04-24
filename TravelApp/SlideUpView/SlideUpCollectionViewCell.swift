//
//  SlideUpCollectionViewCell.swift
//  TravelApp
//
//  Created by Richard Wollack on 4/13/17.
//  Copyright © 2017 Scott Franklin. All rights reserved.
//

import UIKit

class SlideUpCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func draw(_ rect: CGRect) {
        imageView.bounds.size.width = imageView.bounds.size.height
        imageView.layer.cornerRadius = imageView.bounds.size.width / 2
        imageView.layer.masksToBounds = true
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 1.0
        
        backgroundColor = .clear
        backgroundView?.backgroundColor = .clear
    }

}

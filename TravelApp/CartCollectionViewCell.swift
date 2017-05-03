//
//  CartCollectionViewCell.swift
//  TravelApp
//
//  Created by Richard Wollack on 5/2/17.
//  Copyright © 2017 Scott Franklin. All rights reserved.
//

import UIKit
import Cosmos 

class CartCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var openLabel: UILabel!
    @IBOutlet weak var deleteButton: CartDeleteButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        ratingView.settings.fillMode = .precise
        ratingView.backgroundColor = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        let gradient: CAGradientLayer = CAGradientLayer()
        
        gradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradient.locations = [0.0 , 1.0]
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: blurView.frame.size.width, height: blurView.frame.size.height)
        
        blurView.layer.insertSublayer(gradient, at: 0)
        
        deleteButton.layer.cornerRadius = deleteButton.bounds.height / 2
    }
    
    let animationRotateDegres: CGFloat = 0.5
    let animationTranslateX: CGFloat = 1.0
    let animationTranslateY: CGFloat = 1.0
    let count: Int = 1
    
    func wobble() {
        let leftOrRight: CGFloat = (count % 2 == 0 ? 1 : -1)
        let rightOrLeft: CGFloat = (count % 2 == 0 ? -1 : 1)
        let leftWobble: CGAffineTransform = CGAffineTransform(rotationAngle: degreesToRadians(x: animationRotateDegres * leftOrRight))
        let rightWobble: CGAffineTransform = CGAffineTransform(rotationAngle: degreesToRadians(x: animationRotateDegres * rightOrLeft))
        let moveTransform: CGAffineTransform = leftWobble.translatedBy(x: -animationTranslateX, y: -animationTranslateY)
        let conCatTransform: CGAffineTransform = leftWobble.concatenating(moveTransform)
        
        transform = rightWobble
        deleteButton.isHidden = false
        
        UIView.animate(withDuration: 0.1, delay: 0.1, options: [.allowUserInteraction, .repeat, .autoreverse], animations: { () -> Void in
            self.transform = conCatTransform
        }, completion: nil)
    }
    
    func degreesToRadians(x: CGFloat) -> CGFloat {
        return CGFloat.pi * x / 180.0
    }
    @IBOutlet weak var deleteButtonAction: UIButton!
}

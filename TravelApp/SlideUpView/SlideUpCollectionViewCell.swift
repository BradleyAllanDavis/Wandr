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
    var placeId: String!
    var indexPath: IndexPath!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(cellDoubleTapped(gesture:)))
        doubleTapGesture.numberOfTapsRequired = 2
        self.addGestureRecognizer(doubleTapGesture)
    }
    
    func cellDoubleTapped(gesture: UITapGestureRecognizer) {
        if PlaceStore.shared.savePlaceToCart(placeId: placeId) {
            layer.borderColor = UIColor.red.cgColor
            let width = self.frame.width / 2
            let iv = UIImageView(frame: CGRect(x: self.frame.width / 2, y: self.frame.width / 2, width: 0, height: 0))
            iv.image = #imageLiteral(resourceName: "heart.png")
            iv.alpha = 0.0
            contentView.addSubview(iv)
            
            UIView.animate(withDuration: 0.5, animations: {
                iv.frame = CGRect(x: self.frame.width / 4, y: (self.frame.width / 4) - 20, width: width, height: width)
                iv.alpha = 1.0
            }, completion: { (finished: Bool) in
                UIView.animate(withDuration: 0.5, animations: {
                    iv.alpha = 0.0
                }, completion: { (finished: Bool) in
                    iv.removeFromSuperview()
                })
            })
        }
    }
    
    override func draw(_ rect: CGRect) {
        imageView.bounds.size.width = imageView.bounds.size.height
        imageView.layer.cornerRadius = imageView.bounds.size.width / 2
        imageView.layer.masksToBounds = true
        imageView.layer.borderColor = UIColor.black.cgColor
        imageView.layer.borderWidth = 1.0
        
        backgroundColor = .clear
        backgroundView?.backgroundColor = .clear
    }

}

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
    weak var collectionView: UICollectionView!
    var slideView: SlideUpView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(cellDoubleTapped(gesture:)))
        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(cellSingleTapped(gesture:)))
        
        doubleTapGesture.numberOfTapsRequired = 2
        singleTapGesture.numberOfTapsRequired = 1
        
        self.addGestureRecognizer(doubleTapGesture)
        self.addGestureRecognizer(singleTapGesture)
        
        singleTapGesture.require(toFail: doubleTapGesture)
    }
    
    func cellSingleTapped(gesture: UITapGestureRecognizer) {
        print("Single tapped")
        if indexPath.row >= PlaceStore.shared.nearbyPlaces.count {
            PlaceStore.shared.apiSearchMode = .morePlaces
            PlaceStore.shared.updateCurrentPlaces(with: PlaceStore.shared.currentSearchCoordinate!, searchRadius: 4000)
            self.rotate360Degrees(duration: 0.5)
        } else {
            slideView.parentVc.transitionToSwipeView(index: indexPath.row, dataType: .nearby)
        }
    }
    
    func cellDoubleTapped(gesture: UITapGestureRecognizer) {
        if indexPath.row < PlaceStore.shared.nearbyPlaces.count {
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
    }
    
    func rotate360Degrees(duration: CFTimeInterval = 1.0, completionDelegate: AnyObject? = nil) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat.pi * 2.0
        rotateAnimation.duration = duration
        
        if let delegate: AnyObject = completionDelegate {
            rotateAnimation.delegate = delegate as? CAAnimationDelegate
        }
        
        self.imageView.layer.add(rotateAnimation, forKey: nil)
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

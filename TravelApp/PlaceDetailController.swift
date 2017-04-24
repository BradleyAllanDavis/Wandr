//
//  PlaceDetailViewController.swift
//  TravelApp
//
//  Created by Macbook on 4/11/17.
//  Copyright © 2017 Scott Franklin. All rights reserved.
//

import UIKit

class PlaceDetailController: UIViewController
{
    var currentPlace: Dictionary<String, Any>?
    @IBOutlet weak var chevron: UIImageView!
    @IBOutlet weak var placeTitle: UILabel!
    
    var popupView: UIView!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        blur.frame = self.view.bounds
        self.view.addSubview(blur)
        self.view.sendSubview(toBack: blur)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipe(_:)))
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipe(_:)))
        swipeUp.direction = .up
        view.addGestureRecognizer(swipeUp)
    }
    
    func handleSwipe(_ gesture: UIGestureRecognizer) {
        if let swipeDirection = gesture as? UISwipeGestureRecognizer {
            switch swipeDirection.direction {
            case UISwipeGestureRecognizerDirection.up:
                // Add to cart
                self.addPlaceToCart()
            case UISwipeGestureRecognizerDirection.down:
                self.dismiss(animated: true, completion: nil)
            default:
                break
            }
        }
    }
    
    func addPlaceToCart() {
        
        popupView = UIView(frame: CGRect(x: self.view.center.x - 75, y: self.view.center.y - 100, width: 150, height: 150))
        popupView.backgroundColor = UIColor.lightGray
        popupView.layer.cornerRadius = 30
        self.view.addSubview(popupView)
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = popupView.bounds
        blurEffectView.clipsToBounds = true
        blurEffectView.layer.cornerRadius = 30
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        popupView.addSubview(blurEffectView)
        
        let cart = UIImage(named: "shopping-cart-7")
        let cartView = UIImageView(frame: CGRect(x: 50, y: 40, width: 50, height: 50))
        cartView.image = cart
        popupView.addSubview(cartView)

        let addedToCart = UILabel(frame: CGRect(x: 0, y: 100, width: 150, height: 50))
        addedToCart.textColor = .black
        addedToCart.textAlignment = .center
        addedToCart.text = "Added to Cart"
        popupView.addSubview(addedToCart)
        
        

        Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(self.dismissAlert), userInfo: nil, repeats: false)
    }
    
    func dismissAlert() {
        if popupView != nil { // Dismiss the view from here
            popupView.removeFromSuperview()
        }
    }
}

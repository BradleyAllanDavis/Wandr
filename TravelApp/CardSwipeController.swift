//
//  CardSwipe.swift
//  TravelApp
//
//  Created by Jason Cheng on 4/22/17.
//  Copyright © 2017 Scott Franklin. All rights reserved.
//

import Foundation
import Cartography
import ZLSwipeableViewSwift

enum SwipeViewDataType {
    case popular
    case nearby
}

class CardSwipeController: UIViewController {

    var swipeableView: ZLSwipeableView!
    var rect : CGRect!
    var loadCardsFromXib = true
    
    var viewControllers : [CardContentViewController] = []
    var topViewIdx = -1
    var nextLoadViewIdx = 0
    var dataType: SwipeViewDataType = .popular
    
    // Passed in from map view
    var placeIndex = -1
    var popupView: UIView!
    
    let supportTypes: [String] = ["park", "night_club", "movie_theater", "casino", "bar", "art_gallery", "aquarium", "museum", "restaurant"]
    let colorValues: [String:UIColor] = ["default" : UIColor.init(red: 181/255.0, green: 230/255.0, blue: 162/255.0, alpha: 1),
                                         "night_club" : UIColor.init(red: 0/255.0, green: 51/255.0, blue: 102/255.0,alpha: 1),
                                         "museum" : UIColor.init(red: 215/255.0, green: 158/255.0, blue: 0/255.0, alpha: 1),
                                         "art_gallery" : UIColor.init(red: 202/255.0, green: 120/255.0, blue: 120/255.0, alpha: 1),
                                         "casino" : UIColor.init(red: 171/255.0, green: 143/255.0, blue: 193/255.0, alpha: 1),
                                         "park" : UIColor.init(red: 181/255.0, green: 230/255.0, blue: 162/255.0, alpha: 1),
                                         "aquarium" : UIColor.init(red: 70/255.0, green: 170/255.0, blue: 255/255.0, alpha: 1),
                                         "movie_theater" : UIColor.init(red: 89/255.0, green: 44/255.0, blue: 99/255.0, alpha: 1),
                                         "restaurant" : UIColor.init(red: 255/255.0, green: 130/255.0, blue: 0/255.0, alpha: 1),
                                         "bar" : UIColor.init(red: 36/255.0, green: 100/255.0, blue: 241/255.0, alpha: 1)]
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        swipeableView.nextView = {
            return self.nextCardView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(photosDidUpdate(notification:)),
            name: Notification.Name(rawValue: "AddedNewPhoto"),
            object: nil
        )

        rect = CGRect(
            origin: CGPoint(x: 0, y: 0),
            size: CGSize(width: self.view.bounds.width-20, height: self.view.bounds.height-40)
        )
        
        let dataSource: [[String: AnyObject]]
        if dataType == .popular {
            let newData = PlaceStore.shared.popularPlaces
            let part1 = Array(newData[placeIndex..<newData.count])
            let part2 = Array(newData[0..<placeIndex])
            dataSource = part1 + part2
        } else {
            let newData = PlaceStore.shared.nearbyPlaces
            let part1 = Array(newData[placeIndex..<newData.count])
            let part2 = Array(newData[0..<placeIndex])
            dataSource = part1 + part2
        }
        
        // Start at placeIndex...
        for i in 0..<dataSource.count {
            
            let placeViewController = CardContentViewController(nibName: "CardContentView", bundle: nil)
            let placeView = placeViewController.view!
            let placeData = dataSource[i]
            
            // Set text
            placeViewController.placeId = placeData["place_id"] as? String
            placeViewController.label.text = placeData["name"] as? String
            placeViewController.vicinity.text = placeData["vicinity"] as? String
            if placeData.index(forKey: "rating") != nil {
                placeViewController.starLabel?.rating = Double(placeData["rating"] as! Float)
            }
            
            // Set type
            let types = placeData["types"] as! [String]
            for type in types {
                if supportTypes.contains(type) {
                    placeViewController.type = type
                    break
                }
            }
            
            // Set photo
            let photo = PlaceStore.shared.getPhoto(for: placeData["place_id"] as! String)
            placeViewController.imageView.image = photo.image
            placeViewController.imageView.layer.masksToBounds = true
            placeViewController.imageView.layer.cornerRadius = 10.0
            placeViewController.imageView.frame = CGRect(x: 5, y: placeView.frame.minY + 5, width: placeView.frame.width - 10, height: 250)
            
            viewControllers.append(placeViewController)
            
        }
        
        // Transparent navigation bar
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        
        view.backgroundColor = UIColor.white
        view.clipsToBounds = true
        
        swipeableView = ZLSwipeableView()
        swipeableView.allowedDirection = [.Left, .Right, .Down]
        self.view.addSubview(swipeableView)
        
        /* swipeableView.didStart = {view, location in
            print("Did start swiping view at location: \(location)")
        }
        swipeableView.swiping = {view, location, translation in
            print("Swiping at view location: \(location) translation: \(translation)")
        }
        swipeableView.didEnd = {view, location in
            print("Did end swiping view at location: \(location)")
        }
        swipeableView.didCancel = {view in
            print("Did cancel swiping view")
        }
        swipeableView.didDisappear = { view in
            print("Did disappear swiping view")
        } */
        
        swipeableView.didTap = {view, location in
            let topViewController = self.viewControllers[self.topViewIdx]
            let label = topViewController.label.text!
            var type = "nil"
            if let optType = topViewController.type {
                type = optType
            }
            print("Top card is #\(self.topViewIdx): \(label), with type \(type)")
        }
        
        swipeableView.didSwipe = {view, direction, vector in
//            print("Did swipe view in direction: \(direction), vector: \(vector)")
            
            if direction == .Right {
                print("Swiped right, Add to cart")
                
                self.popupView = UIView(frame: CGRect(x: self.view.center.x - 75, y: self.view.center.y - 100, width: 150, height: 150))
                self.popupView.backgroundColor = UIColor.clear
                self.popupView.layer.cornerRadius = 30
                self.view.addSubview(self.popupView)
                
                let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
                let blurEffectView = UIVisualEffectView(effect: blurEffect)
                blurEffectView.frame = self.popupView.bounds
                blurEffectView.clipsToBounds = true
                blurEffectView.layer.cornerRadius = 30
                blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                self.popupView.addSubview(blurEffectView)
                
                let cart = UIImage(named: "shopping-cart-7")
                let cartView = UIImageView(frame: CGRect(x: 50, y: 40, width: 50, height: 50))
                cartView.image = cart
                self.popupView.addSubview(cartView)
                
                let addedToCart = UILabel(frame: CGRect(x: 0, y: 100, width: 150, height: 50))
                addedToCart.textColor = .black
                addedToCart.textAlignment = .center
                addedToCart.text = "Added to Cart"
                self.popupView.addSubview(addedToCart)
                
                Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.dismissPopup), userInfo: nil, repeats: false)
                
                print("Swiped right. Top card \(self.topViewIdx), next card \(self.nextLoadViewIdx), total card num \(self.viewControllers.count)")
                
                if self.viewControllers.count <= 1 {
                    print("No more cards, exit card view")
                    self.dismiss(animated: true, completion: nil)
                    return
                }
                
                let placeViewController = self.viewControllers.remove(at: self.topViewIdx)
                if self.topViewIdx >= self.viewControllers.count {
                    self.topViewIdx = 0
                }
                if self.topViewIdx < self.nextLoadViewIdx {
                    self.nextLoadViewIdx -= 1
                }
                let place = PlaceStore.shared.getPlace(for: placeViewController.placeId!)
                if !PlaceStore.shared.cartPlaceIds.contains(place?["place_id"] as! String) {
                    PlaceStore.shared.savePlaceToCart(placeId: place?["place_id"] as! String)
                }
            }
            if direction == .Left {
                print("Swiped left, dismiss place")

                self.popupView = UIView(frame: CGRect(x: self.view.center.x - 75, y: self.view.center.y - 100, width: 150, height: 150))
                self.popupView.backgroundColor = UIColor.clear
                self.popupView.layer.cornerRadius = 30
                self.view.addSubview(self.popupView)
                
                let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
                let blurEffectView = UIVisualEffectView(effect: blurEffect)
                blurEffectView.frame = self.popupView.bounds
                blurEffectView.clipsToBounds = true
                blurEffectView.layer.cornerRadius = 30
                blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                self.popupView.addSubview(blurEffectView)
                
                let thumb = UIImage(named: "pin-map-off-7")
                let thumbView = UIImageView(frame: CGRect(x: 50, y: 40, width: 50, height: 50))
                thumbView.image = thumb
                self.popupView.addSubview(thumbView)
                
                let notInterested = UILabel(frame: CGRect(x: 0, y: 100, width: 150, height: 50))
                notInterested.textColor = .black
                notInterested.textAlignment = .center
                notInterested.text = "Not Interested"
                self.popupView.addSubview(notInterested)
                
                Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.dismissPopup), userInfo: nil, repeats: false)
                
                print("Swiped left. Top card \(self.topViewIdx), next card \(self.nextLoadViewIdx), total card num \(self.viewControllers.count)")
                
                if self.viewControllers.count < 4 && self.topViewIdx == self.viewControllers.count - 1 {
                    print("No more cards, exit card view")
                    self.dismiss(animated: true, completion: nil)
                }
                self.topViewIdx = (self.topViewIdx + 1) % self.viewControllers.count
            }
            if direction == .Down {
                print("Swiped down, dismiss swipeview")
                self.dismiss(animated: true, completion: nil)
            }
        }
        
        constrain(swipeableView, view) { view1, view2 in
            view1.left == view2.left+50
            view1.right == view2.right-50
            view1.top == view2.top + 120
            view1.bottom == view2.bottom - 100
        }
    }
    
    func dismissPopup() {
//        print("dismiss popup")
        if self.popupView != nil { // Dismiss the view from here
            self.popupView.removeFromSuperview()
        }
    }
    
    func photosDidUpdate(notification: Notification) {
        let placeId = notification.userInfo?["placeId"] as! String
        let photo = notification.object as! PlacePhoto
        
        for case let viewController in viewControllers {
            if viewController.placeId == placeId {
                viewController.imageView?.image = photo.image
                break
            }
        }
    }
    
    func leftButtonAction() {
        self.swipeableView.swipeTopView(inDirection: .Left)
    }
    
    func upButtonAction() {
        self.swipeableView.swipeTopView(inDirection: .Up)
    }
    
    func rightButtonAction() {
        self.swipeableView.swipeTopView(inDirection: .Right)
    }
    
    func downButtonAction() {
        self.swipeableView.swipeTopView(inDirection: .Down)
    }
    
    // MARK: ()
    func nextCardView() -> UIView? {
        
        print("Top card is \(topViewIdx), requesting card \(nextLoadViewIdx), total card number \(viewControllers.count)")
        
        if nextLoadViewIdx >= viewControllers.count && viewControllers.count > 4 {
            nextLoadViewIdx = 0
        }
        
        if nextLoadViewIdx < 0 || nextLoadViewIdx >= viewControllers.count || nextLoadViewIdx == topViewIdx {  // out of cards
            return nil
        }
        
        if topViewIdx < 0 {
            topViewIdx = 0
        }
        
        let cardView = CardView(frame: rect)
        let contentViewController = viewControllers[nextLoadViewIdx]
        let contentView = contentViewController.view!
        
        // Set backgroundColor
        cardView.backgroundColor = colorValues["default"]
        if let type = contentViewController.type {
            if let color = colorValues[type] {
                cardView.backgroundColor = color
            }
        }
        
        nextLoadViewIdx += 1
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = cardView.backgroundColor
        cardView.addSubview(contentView)
        constrain(contentView, cardView) { view1, view2 in
            view1.left == view2.left
            view1.top == view2.top
            view1.width == cardView.bounds.width
            view1.height == cardView.bounds.height
        }
        
        return cardView
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension UIColor {
    
    func lighter(by percentage:CGFloat=30.0) -> UIColor? {
        return self.adjust(by: abs(percentage) )
    }
    
    func darker(by percentage:CGFloat=30.0) -> UIColor? {
        return self.adjust(by: -1 * abs(percentage) )
    }
    
    func adjust(by percentage:CGFloat=30.0) -> UIColor? {
        var r:CGFloat=0, g:CGFloat=0, b:CGFloat=0, a:CGFloat=0;
        if (self.getRed(&r, green: &g, blue: &b, alpha: &a)){
            return UIColor(red: min(r + percentage/100, 1.0),
                           green: min(g + percentage/100, 1.0),
                           blue: min(b + percentage/100, 1.0),
                           alpha: a)
        } else {
            return nil
        }
    }
}

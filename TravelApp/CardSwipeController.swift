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
    
    var views : [UIView] = []
    var viewColors : [UIColor] = []
    var viewIndex = 0
    
    var dataType: SwipeViewDataType = .popular
    
    // Passed in from map view
    var placeIndex = -1
    
    var popupView: UIView!
    
    var colors = UIColor.flatUIColors()
    var colorIndex = 0
    var loadCardsFromXib = false
    
    let colorValues: [String:UIColor] = ["night_club" : UIColor.init(red: 0/255.0, green: 51/255.0, blue: 102/255.0,alpha: 1),
                                          "museum" : UIColor.init(red: 215/255.0, green: 158/255.0, blue: 0/255.0, alpha: 1),
                                          "art_gallery" : UIColor.init(red: 202/255.0, green: 120/255.0, blue: 120/255.0, alpha: 1),
                                          "casino" : UIColor.init(red: 171/255.0, green: 143/255.0, blue: 193/255.0, alpha: 1),
                                          "park" : UIColor.init(red: 181/255.0, green: 230/255.0, blue: 162/255.0, alpha: 1),
                                          "aquarium" : UIColor.init(red: 70/255.0, green: 170/255.0, blue: 255/255.0, alpha: 1),
                                          "movie_theater" : UIColor.black,
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

        let rect = CGRect(
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
            let placeView = TestView1(frame: rect)
            let placeData = dataSource[i]
            
            placeView.placeId = placeData["place_id"] as? String
            placeView.label?.text = placeData["name"] as? String
            placeView.vicinity?.text = placeData["vicinity"] as? String
            
            if placeData.index(forKey: "rating") != nil {
                placeView.starLabel?.rating = Double(placeData["rating"] as! Float)
            }
            
            let types = placeData["types"] as! [String]
            let placeType = types[0]
            
            let photo = PlaceStore.shared.getPhoto(for: placeData["place_id"] as! String)
            placeView.imageView?.image = photo.image
            placeView.imageView?.layer.masksToBounds = true
            placeView.imageView?.layer.cornerRadius = 10.0
            placeView.imageView?.frame = CGRect(x: 5, y: placeView.frame.minY + 5, width: placeView.frame.width - 10, height: 250)
            
            if colorValues[placeType] != nil {
                viewColors.append(colorValues[placeType]!)
            } else {
                viewColors.append(colorValues["park"]!)
            }
            views.append(placeView)
        }
        
        // Transparent navigation bar
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        
        view.backgroundColor = UIColor.white
        view.clipsToBounds = true
        
        swipeableView = ZLSwipeableView()
        swipeableView.allowedDirection = .All
        self.view.addSubview(swipeableView)
        swipeableView.didStart = {view, location in
            print("Did start swiping view at location: \(location)")
        }
        swipeableView.swiping = {view, location, translation in
            print("Swiping at view location: \(location) translation: \(translation)")
        }
        swipeableView.didEnd = {view, location in
            print("Did end swiping view at location: \(location)")
        }
        swipeableView.didSwipe = {view, direction, vector in
            print("Did swipe view in direction: \(direction), vector: \(vector)")
            
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
                
                let placeView: TestView1 = self.views.remove(at: 0) as! TestView1
                let place = PlaceStore.shared.getPlace(for: placeView.placeId!)
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
            }
            if direction == .Up {
                print("Swiped up, dismiss place")
                
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
            }
            if direction == .Down {
                print("Swiped left, dismiss swipeview")
                self.dismiss(animated: true, completion: nil)
            }
        }
        swipeableView.didCancel = {view in
            print("Did cancel swiping view")
        }
        swipeableView.didTap = {view, location in
            print("Did tap at location \(location)")
        }
        swipeableView.didDisappear = { view in
            print("Did disappear swiping view")
        }
        constrain(swipeableView, view) { view1, view2 in
            view1.left == view2.left+50
            view1.right == view2.right-50
            view1.top == view2.top + 120
            view1.bottom == view2.bottom - 100
        }
    }
    
    func dismissPopup() {
        print("dismiss popup")
        if self.popupView != nil { // Dismiss the view from here
            self.popupView.removeFromSuperview()
        }
    }
    
    func photosDidUpdate(notification: Notification) {
        let placeId = notification.userInfo?["placeId"] as! String
        let photo = notification.object as! PlacePhoto
        
        for case let view as TestView1 in views {
            if view.placeId == placeId {
                view.imageView?.image = photo.image
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
        
        if viewIndex >= views.count {
            return nil
        }
        
        let cardView = views[viewIndex]
        cardView.backgroundColor = viewColors[viewIndex]
        viewIndex += 1
        
        if colorIndex >= colors.count {
            colorIndex = 0
        }
        //cardView.backgroundColor = colors[colorIndex].lighter(by: 40.0)
        //colorIndex += 1
        
        
        if loadCardsFromXib {
            let contentView = Bundle.main.loadNibNamed("CardContentView", owner: self, options: nil)?.first! as! UIView
            contentView.translatesAutoresizingMaskIntoConstraints = false
            contentView.backgroundColor = cardView.backgroundColor
            cardView.addSubview(contentView)
            
            // This is important:
            // https://github.com/zhxnlai/ZLSwipeableView/issues/9
            /*// Alternative:
             let metrics = ["width":cardView.bounds.width, "height": cardView.bounds.height]
             let views = ["contentView": contentView, "cardView": cardView]
             cardView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[contentView(width)]", options: .AlignAllLeft, metrics: metrics, views: views))
             cardView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[contentView(height)]", options: .AlignAllLeft, metrics: metrics, views: views))
             */
            constrain(contentView, cardView) { view1, view2 in
                view1.left == view2.left
                view1.top == view2.top
                view1.width == cardView.bounds.width
                view1.height == cardView.bounds.height
            }
        }
        return cardView
    }
    
    func loadCardViews(viewsToSet : [UIView]) {
        views = viewsToSet
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

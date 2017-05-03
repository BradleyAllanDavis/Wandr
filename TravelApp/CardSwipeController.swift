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
    var viewIndex = 0
    
    var dataType: SwipeViewDataType = .popular
    
    // Passed in from map view
    var placeIndex = -1
    
    var colors = UIColor.flatUIColors()
    var colorIndex = 0
    var loadCardsFromXib = false
    
    var reloadBarButtonItem: UIBarButtonItem!
    // var reloadBarButtonItem = UIBarButtonItem(barButtonSystemItem: "Reload", target: .Plain) { item in }
    var leftBarButtonItem: UIBarButtonItem!
    // var leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: "←", target: .Plain) { item in }
    var upBarButtonItem: UIBarButtonItem!
    // var upBarButtonItem = UIBarButtonItem(barButtonSystemItem: "↑", target: .Plain) { item in }
    var rightBarButtonItem: UIBarButtonItem!
    // var rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: "→", target: .Plain) { item in }
    var downBarButtonItem:UIBarButtonItem!
    // var downBarButtonItem = UIBarButtonItem(barButtonSystemItem: "↓", target: .Plain) { item in }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        swipeableView.nextView = {
            return self.nextCardView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
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
            let photo = PlaceStore.shared.getPhoto(for: placeData["place_id"] as! String)
            
            placeView.label?.text = placeData["name"] as? String
            placeView.imageView?.image = photo.image
            placeView.placeId = placeData["place_id"] as? String
            
            
            views.append(placeView)
        }
        
        // ...and then append the rest, needed?
//        for i in 0..<placeIndex {
//            let placeView = TestView1(frame: rect)
//            let placeData = PlaceStore.shared.popularPlaces[i]
//            let photo = PlaceStore.shared.getPhoto(for: placeData["place_id"] as! String)
//            
//            placeView.label?.text = placeData["name"] as? String
//            
//            //if photo.status == .downloaded {
//            placeView.image = photo.image
//            //}
//            views.append(placeView)
//        }
        
        // Transparent navigation bar
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        
        view.backgroundColor = UIColor.white
        view.clipsToBounds = true
        
        /*
        reloadBarButtonItem = UIBarButtonItem(title: "Reload", style: .plain, target: self, action: #selector(reloadButtonAction))
        leftBarButtonItem = UIBarButtonItem(title: "←", style: .plain, target: self, action: #selector(leftButtonAction))
        upBarButtonItem = UIBarButtonItem(title: "↑", style: .plain, target: self, action: #selector(upButtonAction))
        rightBarButtonItem = UIBarButtonItem(title: "→", style: .plain, target: self, action: #selector(rightButtonAction))
        downBarButtonItem = UIBarButtonItem(title: "↓", style: .plain, target: self, action: #selector(downButtonAction))
        
        let fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        
        let items = [fixedSpace, reloadBarButtonItem!, flexibleSpace, leftBarButtonItem!, flexibleSpace, upBarButtonItem!, flexibleSpace, rightBarButtonItem!, flexibleSpace, downBarButtonItem!, fixedSpace]
        toolbarItems = items*/
        
        swipeableView = ZLSwipeableView()
        swipeableView.allowedDirection = Direction.Right
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
    
    func reloadButtonAction() {
        let alertController = UIAlertController(title: nil, message: "Load Cards:", preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            // ...
        }
        alertController.addAction(cancelAction)
        
        let ProgrammaticallyAction = UIAlertAction(title: "Programmatically", style: .default) { (action) in
            self.loadCardsFromXib = false
            self.colorIndex = 0
            self.swipeableView.discardViews()
            self.swipeableView.loadViews()
        }
        alertController.addAction(ProgrammaticallyAction)
        
        let XibAction = UIAlertAction(title: "From Xib", style: .default) { (action) in
            self.loadCardsFromXib = true
            self.colorIndex = 0
            self.swipeableView.discardViews()
            self.swipeableView.loadViews()
        }
        alertController.addAction(XibAction)
        
        self.present(alertController, animated: true, completion: nil)
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
        viewIndex += 1
        
        if colorIndex >= colors.count {
            colorIndex = 0
        }
        cardView.backgroundColor = colors[colorIndex]
        colorIndex += 1
        
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

//
//  SlideUpView.swift
//  TravelApp
//
//  Created by Richard Wollack on 4/12/17.
//  Copyright © 2017 Scott Franklin. All rights reserved.
//

import UIKit 

struct SlideUpViewOrigins {
    let wayDown = CGPoint(x: 12.5, y: UIScreen.main.bounds.height - 35)
    let middle = CGPoint(x: 0.0, y: UIScreen.main.bounds.height - 150)
    let wayUp = CGPoint(x: 0.0, y: 75)
    let defaultSize = CGSize(width: UIScreen.main.bounds.width - 25, height: UIScreen.main.bounds.height - 75)
    let shiftedSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 75)
}

class SlideUpView: UIVisualEffectView {
    let origins = SlideUpViewOrigins()
    var currentOrigin: CGPoint!
    var lastLocation: CGPoint!
    var wayDownLabel = UILabel(frame: CGRect(x: 15, y: 5, width: 100, height: 20))
    var collectionView: UICollectionView!
    var tableView: UITableView!
    let data = ["one", "two", "three", "four"]
    var nearbyPlaces = [Dictionary<String, AnyObject>]()
    var popularPlaces = [Dictionary<String, AnyObject>]()
    private var panGesture: UIPanGestureRecognizer!
    
    override init(effect: UIVisualEffect?) {
        super.init(effect: effect)
        
        setupPanGesture()
        
        let labelFont = UIFont(name: "Avenir", size: 14)
        
        frame = CGRect(origin: origins.wayDown, size: origins.defaultSize)
        currentOrigin = frame.origin
        layer.cornerRadius = 5.0
        clipsToBounds = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(updatePlaces(notification:)), name: Notification.Name(rawValue: "ReceivedNewPlaces"), object: nil)
        
        wayDownLabel.font = labelFont
        wayDownLabel.text = "Nearby Places"
        wayDownLabel.textColor = .white
        
        addSubview(wayDownLabel)
        setupCollectionView()
        setupTableView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func updatePlaces(notification: Notification) {
        nearbyPlaces = PlaceStore.shared.nearbyPlaces
        popularPlaces = PlaceStore.shared.popularPlaces
        
        collectionView.reloadData()
        tableView.reloadData()
    }
    
    func setupCollectionView() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        layout.itemSize = CGSize(width: 100, height: 100)
        layout.scrollDirection = .horizontal
        
        let collectionViewFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 150)
        
        collectionView = UICollectionView(frame: collectionViewFrame, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "SlideUpCollectionViewCell", bundle: .main), forCellWithReuseIdentifier: "slideCollectionCell")
        collectionView.backgroundColor = .white
        collectionView.isHidden = true

        addSubview(collectionView)
    }
    
    func setupTableView() {
        let tableViewFrame = CGRect(x: 0, y: 150, width: UIScreen.main.bounds.size.width, height: frame.height)
        
        tableView = UITableView(frame: tableViewFrame, style: .plain)
        tableView.isUserInteractionEnabled = true
        tableView.register(UINib(nibName: "PopularTableViewCell", bundle: .main), forCellReuseIdentifier: "popularTableCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isHidden = true
        tableView.backgroundColor = .clear
        
        addSubview(tableView)
    }
    
    func setupPanGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(dragRecognizer(gesture:)))
        addGestureRecognizer(panGesture)
    }
    
    func dragRecognizer(gesture: UIPanGestureRecognizer) {
        let velocity = gesture.velocity(in: gesture.view)
        
        if gesture.state == .began {
            checkPanDirection(velocity: velocity)
        }
    }
    
    func checkPanDirection(velocity: CGPoint) {
        if fabs(velocity.y) > fabs(velocity.x) {
            if velocity.y > 0 {
                didDragDown()
            } else {
                didDragUp()
            }
        }
    }
    
    override func touchesBegan(_ touches: (Set<UITouch>!), with event: UIEvent!) {
        self.superview?.bringSubview(toFront: self)
        lastLocation = frame.origin
    }
    
    func didDragUp() {
        switch currentOrigin {
        case origins.wayDown:
            animateMiddle()
            break
        case origins.middle:
            animateWayUp()
            break
        default:
            break
        }
    }
    
    func didDragDown() {
        switch currentOrigin {
        case origins.wayUp:
            animateMiddle()
            break
        case origins.middle:
            animateWayDown()
        default:
            break
        }
    }
    
    func animateMiddle() {
        UIView.animate(withDuration: 0.5, delay: 0.1, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, options: .curveEaseOut, animations: {
            self.frame = CGRect(origin: self.origins.middle, size: self.origins.shiftedSize)
            self.currentOrigin = self.origins.middle
            self.layer.cornerRadius = 0.0
            self.collectionView.isHidden = false
            self.tableView.frame.origin.y = 150
            self.wayDownLabel.isHidden = false
        }, completion: { _ in
            
        })
    }
    
    func animateWayUp(completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: 0.5, delay: 0.1, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, options: .curveEaseOut, animations: {
            self.frame = CGRect(origin: self.origins.wayUp, size: self.origins.shiftedSize)
            self.currentOrigin = self.origins.wayUp
            self.layer.cornerRadius = 0.0
            self.collectionView.isHidden = true
            self.tableView.frame.origin.y = 0.0
            self.tableView.isHidden = false
            self.wayDownLabel.isHidden = true
        }, completion: nil)
    }
    
    func animateWayDown() {
        UIView.animate(withDuration: 0.5, delay: 0.1, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, options: .curveEaseOut, animations: {
            self.frame = CGRect(origin: self.origins.wayDown, size: self.origins.defaultSize)
            self.currentOrigin = self.origins.wayDown
            self.layer.cornerRadius = 5.0
            self.collectionView.isHidden = true
        }, completion: nil)
    }
}

//# MARK: - UICollectionView delegage methods

extension SlideUpView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return nearbyPlaces.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "slideCollectionCell", for: indexPath) as! SlideUpCollectionViewCell
        
        if nearbyPlaces[indexPath.row].index(forKey: "name") != nil {
            cell.titleLabel.text = nearbyPlaces[indexPath.row]["name"] as? String
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.size.width / 2
        let height = collectionView.frame.height
        
        return CGSize(width: width, height: height)
    }
}

//# MARK: - UITableView methods

extension SlideUpView: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return popularPlaces.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "popularTableCell", for: indexPath) as! PopularTableViewCell
        
        if popularPlaces[indexPath.row].index(forKey: "name") != nil {
            cell.titleLabel.text = popularPlaces[indexPath.row]["name"] as? String
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let effect = UIBlurEffect(style: .light)
        let header = UIVisualEffectView(effect: effect)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(dragRecognizer(gesture:)))
        
        header.frame = CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 50)
        header.addGestureRecognizer(panGesture)
        
        let headerLabel = UILabel(frame: CGRect(x: 20, y: 0, width: header.frame.width - 20, height: header.frame.height))
        
        headerLabel.text = "Popular"
        headerLabel.font = UIFont(name: "Helectiva", size: 18)
        headerLabel.textColor = .white
        headerLabel.text = "Popular"
        
        header.addSubview(headerLabel)
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
}

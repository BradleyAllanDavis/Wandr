//
//  CartViewController.swift
//  TravelApp
//
//  Created by Macbook on 3/8/17.
//  Copyright © 2017 Scott Franklin. All rights reserved.
//

import UIKit
import GooglePlaces
import Firebase
import FirebaseDatabase
import FirebaseAuth

enum CollectionViewState {
    case normal
    case editing
}

class CartViewController: UIViewController {
    var cartPlaces = [GMSPlace]()
    var cartPhotos = [PlacePhoto]()
    var collectionViewState: CollectionViewState = .normal
    var ref: FIRDatabaseReference!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "My Cart"
        
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = UIScreen.main.bounds
        
        collectionView?.backgroundColor = .clear
        collectionView.backgroundView?.backgroundColor = .clear
        
        view.backgroundColor = .clear
        view.insertSubview(blurEffectView, at: 0)
        
        let placeAPISearch = PlacesAPISearch()
        
        placeAPISearch.gmsPlaceDelegate = self
        placeAPISearch.getGMSPlacesById(placeIds: PlaceStore.shared.cartPlaceIds)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissSelf))
        NotificationCenter.default.addObserver(
            self, selector: #selector(photosDidUpdate(notification:)),
            name: Notification.Name(rawValue: "AddedNewPhoto"),
            object: nil
        )
        
        addGestureRecognizers()
    }
    
    
    
    @IBAction func deleteItemFromCart(_ sender: Any) {
        let button = sender as! CartDeleteButton
        let place = cartPlaces[button.index!]
        
        PlaceStore.shared.removePlacefromCart(placeId: place.placeID)
        cartPlaces.remove(at: button.index!)
        cartPhotos.remove(at: button.index!)
        collectionView.reloadData()
        
        
    }
    
    func addGestureRecognizers() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(startShake(gesture:)))
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(gesture:)))
//        tapGesture.cancelsTouchesInView = false
        
        longPressGesture.minimumPressDuration = 0.3
        longPressGesture.delaysTouchesBegan = true
        
        self.collectionView.addGestureRecognizer(longPressGesture)
        self.collectionView.addGestureRecognizer(tapGesture)
    }
    
    func handleTap(gesture: UITapGestureRecognizer) {
        print("handle tap")
        if collectionViewState == .editing {
            self.endShake(gesture: gesture)
        } else {
            if let indexPath = self.collectionView?.indexPathForItem(at: gesture.location(in: self.collectionView)) {
                self.collectionView(self.collectionView, didSelectItemAt: indexPath)
            }
        }
    }
    
    func startShake(gesture: UILongPressGestureRecognizer) {
        collectionViewState = .editing
        collectionView.reloadData()
    }
    
    func endShake(gesture: UITapGestureRecognizer) {
        print("end shake")
        collectionViewState = .normal
        collectionView.reloadData()
    }
    
    func photosDidUpdate(notification: Notification) {
        collectionView?.reloadData()
    }
    
    func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }
}

extension CartViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cartCell", for: indexPath) as! CartCollectionViewCell
        let photo = cartPhotos[indexPath.row]
        let place = cartPlaces[indexPath.row]
        
        cell.titleLabel.text = place.name
        cell.addressLabel.text = place.formattedAddress
        cell.ratingView.rating = Double(place.rating)
        cell.deleteButton.index = indexPath.row
        
        switch place.openNowStatus {
        case .no:
            cell.openLabel.text = "Closed Now"
            cell.openLabel.textColor = .red
            break
        case .yes:
            cell.openLabel.text = "Open Now"
            cell.openLabel.textColor = .green
            break
        case .unknown:
            cell.openLabel.text = "Hours Unavailable"
            cell.openLabel.textColor = .yellow
            break
        }
        
        if photo.status == .downloaded {
            cell.imageView.image = photo.image
        } else {
            cell.imageView.image = #imageLiteral(resourceName: "Placeholder_location.png")
        }
        
        if collectionViewState == .editing {
            cell.wobble()
        } else {
            cell.deleteButton.isHidden = true
        }
        
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cartPlaces.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (UIScreen.main.bounds.width / 2) - 7.5
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("select place \(cartPlaces[indexPath.row].name)")
        let detailVC = PlaceDetailViewController(nibName: "DetailView", bundle: nil)
        detailVC.placeTitle = cartPlaces[indexPath.row].name
        detailVC.placeID = cartPlaces[indexPath.row].placeID
        detailVC.modalPresentationStyle = .overCurrentContext
        self.present(detailVC, animated: true, completion: nil)
    }
}

extension CartViewController: GMSPlaceRequestDelegate {
    func didReceiveGMSPlace(place: GMSPlace) {
        cartPlaces.append(place)
        let placePhoto = PlaceStore.shared.getPhoto(for: place.placeID)
        cartPhotos.append(placePhoto)
        collectionView?.reloadData()
    }
    
    func gmsPlaceDidReceiveError(error: Error) {
        
    }
}

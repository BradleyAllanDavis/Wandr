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

struct PlaceStruct {
    var placePhoto: PlacePhoto
    var place: GMSPlace
}

class CartViewController: UIViewController {
    var cartPlaces = [GMSPlace]()
    var cartPhotos = [PlacePhoto]()
    var collectionViewState: CollectionViewState = .normal
    var ref: FIRDatabaseReference!
    
    var placeArray = [GMSPlace]()
    var sortedPlaces = [String : [String: [String: [PlaceStruct]]]]()
    
    
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
        let place = getPlaceForIndexPath(indexPath: button.indexPath!)?.place
        
        PlaceStore.shared.removePlacefromCart(placeId: (place?.placeID)!)
        removePlaceAtIndexPath(indexPath: button.indexPath!)
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
//        let photo = cartPhotos[indexPath.row]
//        let place = cartPlaces[indexPath.row]
        let pStruct = getPlaceForIndexPath(indexPath: indexPath)
        
        cell.titleLabel.text = pStruct?.place.name
        cell.addressLabel.text = pStruct?.place.formattedAddress
        cell.ratingView.rating = Double((pStruct?.place.rating)!)
        cell.deleteButton.indexPath = indexPath
        
        
        if pStruct?.placePhoto.status == .downloaded {
            cell.imageView.image = pStruct?.placePhoto.image
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
    
    func getPlaceForIndexPath(indexPath: IndexPath) -> PlaceStruct? {
        var count = 0
        
        for countries in sortedPlaces.values {
            for states in countries.values {
                for places in states.values {
                    if indexPath.section == count {
                        return places[indexPath.row]
                    }
                    
                    count += 1
                }
            }
        }
        
        return nil
    }
    
    func removePlaceAtIndexPath(indexPath: IndexPath) {
        var count = 0
        
        for countryName in sortedPlaces.keys {
            let states = sortedPlaces[countryName]
            
            for stateName in (states?.keys)! {
                let cities = states?[stateName]
                
                for cityName in (cities?.keys)! {
                    if indexPath.section == count {
                        sortedPlaces[countryName]?[stateName]?[cityName]?.remove(at: indexPath.row)
                        
                        if sortedPlaces[countryName]?[stateName]?[cityName]?.count == 0 {
                            sortedPlaces[countryName]?[stateName]?.removeValue(forKey: cityName)
                        }
                        return
                    }
                    
                    count += 1
                }
            }
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        var count = 0
        
       for countries in sortedPlaces.values {
        
            for states in countries.values {

                for _ in states.keys {
                    count += 1
                }
            }
        }
        
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count = 0
        
        for countries in sortedPlaces.values {
            
            for states in countries.values {
                
                for places in states.values {
                    print("count \(places.count)")
                    if section == count {
                        return places.count
                    }
                    
                    count += 1
                }
            }
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "cartHeader", for: indexPath) as! CartCollectionReusableView
        let title = getTitleForSection(indexPath: indexPath)
        headerView.headerTitle.text = title
        
        return headerView
    }
    
    func getTitleForSection(indexPath: IndexPath) -> String {
        var count = 0
        
        for countryName in sortedPlaces.keys {
            let states = sortedPlaces[countryName]
            
            for stateName in (states?.keys)! {
                let cities = states?[stateName]
                
                for cityName in (cities?.keys)! {
                    
                    if indexPath.section == count {
                        return cityName + ", " + stateName + ", " + countryName
                    }
                    
                    count += 1
                }
            }
        }
        
        return ""
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (UIScreen.main.bounds.width / 2) - 7.5
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailVC = PlaceDetailViewController(nibName: "DetailView", bundle: nil)
        let place = getPlaceForIndexPath(indexPath: indexPath)
        detailVC.place = place?.place
        detailVC.modalPresentationStyle = .overCurrentContext
        self.present(detailVC, animated: true, completion: nil)
    }
}

extension CartViewController: GMSPlaceRequestDelegate {
    func didReceiveGMSPlace(place: GMSPlace) {
        
        var country = ""
        var stateRegion = ""
        var city = ""
        
        for component in place.addressComponents! {
            switch component.type {
            case "country":
                country = component.name
                break
            case "administrative_area_level_1":
                stateRegion = component.name
                break
            case "locality":
                city = component.name
                break
            default:
                break
            }
        }
        
        let placePhoto = PlaceStore.shared.getPhoto(for: place.placeID)
        let pStruct = PlaceStruct(placePhoto: placePhoto, place: place)
        
        var countryDict = sortedPlaces[country]
        
        if countryDict == nil {
            countryDict = [String: [String: [PlaceStruct]]]()
            countryDict?[stateRegion] = [String: [PlaceStruct]]()
            countryDict?[stateRegion]?[city] = [pStruct]
        } else {
            var stateDict = countryDict?[stateRegion]
            
            if stateDict == nil {
                countryDict?[stateRegion] = [String: [PlaceStruct]]()
                countryDict?[stateRegion]?[city] = [pStruct]
            } else {
                let cityDict = stateDict?[city]
                
                if cityDict == nil {
                    countryDict?[stateRegion]?[city] = []
                } else {
                    countryDict?[stateRegion]?[city]?.append(pStruct)
                }
            }
        }
        
        sortedPlaces[country] = countryDict
        collectionView?.reloadData()
    }
    
    func gmsPlaceDidReceiveError(error: Error) {
        
    }
}

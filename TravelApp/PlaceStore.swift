//
//  PlaceStore.swift
//  TravelApp
//
//  Created by Richard Wollack on 4/15/17.
//  Copyright © 2017 Scott Franklin. All rights reserved.
//

import UIKit
import GooglePlaces

final class PlaceStore: NSObject {
    static let shared: PlaceStore = PlaceStore()
    
    fileprivate let apiSearch = PlacesAPISearch()
    fileprivate var _photos: [PlacePhoto] = []
    fileprivate var _nearbyPlaces: [Dictionary<String, AnyObject>] = []
    fileprivate var _popularPlaces: [Dictionary<String, AnyObject>] = []
    
    fileprivate let concurrentPhotoQueue = DispatchQueue(label: "placesPhotoQueue", attributes: .concurrent)
    fileprivate let concurrentNearbyPlaceQueue = DispatchQueue(label: "nearbyPlacesQueue", attributes: .concurrent)
    fileprivate let concurrentPopularPlaceQueue = DispatchQueue(label: "PopularPlacesQueue", attributes: .concurrent)
    
    fileprivate var photos: [PlacePhoto] {
        var photosCopy: [PlacePhoto]!
        concurrentPhotoQueue.sync {
            photosCopy = self._photos
        }
        
        return photosCopy
    }
    
    var nearbyPlaces: [Dictionary<String, AnyObject>] {
        var nearbyCopy: [Dictionary<String, AnyObject>]!
        concurrentNearbyPlaceQueue.sync {
            nearbyCopy = self._nearbyPlaces
        }
        
        return nearbyCopy
    }
    
    var popularPlaces: [Dictionary<String, AnyObject>] {
        var popularCopy: [Dictionary<String, AnyObject>]!
        concurrentPopularPlaceQueue.sync {
            popularCopy = self._popularPlaces
        }
        
        return popularCopy
    }
    
    private override init() {
        super.init()
        apiSearch.resultsUpdaterDelegate = self
    }
    
    func updateCurrentPlaces(with location: CLLocationCoordinate2D, searchRadius: Int) {
        apiSearch.requestPlacesByType(location: location, searchRadius: searchRadius)
    }
    
    private func addPhoto(_ photo: PlacePhoto) {
        concurrentPhotoQueue.async(flags: .barrier) {
            self._photos.append(photo)
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "AddedNewPhoto"), object: nil)
            }
        }
    }
    
    func getPhoto(for placeId: String) -> PlacePhoto {
        if let cachedPhoto = photos.filter({
            $0.placeId == placeId
        }).first {
            return cachedPhoto
        } else {
            let photo = PlacePhoto(placeId: placeId) {
                _, error in
                if error != nil {
                    //do something with error
                    print("error getting photo \(error.debugDescription)")
                }
            }
            
            PlaceStore.shared.addPhoto(photo)
            return photo
        }
    }
    
    func getPlace(for placeId: String) -> Dictionary<String, AnyObject>? {
        if let place = nearbyPlaces.filter({
            $0["place_id"] as! String == placeId
        }).first {
            return place
        } else {
            return nil
        }
    }
}

//# MARK: - PlacesAPISearchUpdater methods

extension PlaceStore: PlacesAPISearchResultUpdater {
    func didReceivePlacesFromAPI(places: [Dictionary<String, AnyObject>]) {
        concurrentNearbyPlaceQueue.async(flags: .barrier, execute: {
            self._nearbyPlaces = places
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "ReceivedNewNearbyPlaces"), object: nil)
            }
        })
        
        //just sort nearby places by rating to get popular
        concurrentPopularPlaceQueue.async(flags: .barrier, execute: {
            self._popularPlaces = self._nearbyPlaces.sorted(by: {
                let p1Rating = $0.index(forKey: "rating") != nil
                    ? $0["rating"] as! Double
                    : 0.0
                let p2Rating = $1.index(forKey: "rating") != nil
                    ? $1["rating"] as! Double
                    : 0.0
                
                return ((p1Rating * 10).rounded() / 10) > ((p2Rating * 10).rounded() / 10)
            })
            
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "ReceivedNewPopularPlaces"), object: nil)
            }
        })
    }
    
    func placesAPIDidReceiveErrorForPlaceType(error: Error, placeType: String) {
        print("Error getting places for type \(placeType)")
    }
}


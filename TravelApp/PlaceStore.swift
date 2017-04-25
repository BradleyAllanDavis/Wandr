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
    
    var tagPreferences: [String: Bool]
    var currentNearbyFocusedPlaceIndex: Int = 0
    var currentSearchCoordinate: CLLocationCoordinate2D?
    
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
    
    var userSelectedPlaceTypes: [String] {
        let tagPrefs = tagPreferences.flatMap({ (tag, val) -> String? in
            if val {
                return tag
            }
            return nil
        })
        
        return tagPrefs
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
        let plistManager = Plist(name: "tagPreferences")
        tagPreferences = plistManager?.getValuesInPlistFile() as! [String: Bool]

        super.init()
        
        apiSearch.resultsUpdaterDelegate = self
    }
    
    func updateCurrentPlaces(with location: CLLocationCoordinate2D, searchRadius: Int) {
        currentSearchCoordinate = location
        apiSearch.requestPlacesByType(location: location, searchRadius: searchRadius, types: userSelectedPlaceTypes)
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
    
    func getCurrentFocusedPlace() -> Dictionary<String, AnyObject> {
        return _nearbyPlaces[currentNearbyFocusedPlaceIndex]
    }
    
    func setTags(tags: [String: Bool]) {
        tagPreferences = tags
        let plistManager = Plist(name: "tagPreferences")        
        try! plistManager?.addValuesToPlistFile(dictionary: tags as NSDictionary)
    }
    
    func loadTagsFromPlist() {
        let plistManager = Plist(name: "tagPreferences")
        let tags = plistManager?.getValuesInPlistFile() as! [String: Bool]
        tagPreferences = tags
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
        
        concurrentPhotoQueue.async(flags: .barrier, execute: {
            self._photos.removeAll()
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


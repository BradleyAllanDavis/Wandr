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
    var nearbyPlaces = [Dictionary<String, AnyObject>]()
    var popularPlaces = [Dictionary<String, AnyObject>]()
    var placeImages = [UIImage]()
    private let apiSearch = PlacesAPISearch()
    
    private override init() {
        super.init()
        apiSearch.resultsUpdaterDelegate = self
    }
    
    static let shared: PlaceStore = PlaceStore()
    
    func updateCurrentPlaces(with location: CLLocationCoordinate2D, searchRadius: Int) {
        apiSearch.requestPlacesByType(location: location, searchRadius: searchRadius)
    }
}

//# MARK: - PlacesAPISearchUpdater methods

extension PlaceStore: PlacesAPISearchResultUpdater {
    func didReceivePlacesFromAPI(places: [Dictionary<String, AnyObject>]) {
        nearbyPlaces = places
        popularPlaces = nearbyPlaces.sorted(by: {
            let p1Rating = $0.index(forKey: "rating") != nil
                ? $0["rating"] as! Double
                : 0.0
            let p2Rating = $1.index(forKey: "rating") != nil
                ? $1["rating"] as! Double
                : 0.0
            
            return ((p1Rating * 10).rounded() / 10) > ((p2Rating * 10).rounded() / 10)
        })
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "ReceivedNewPlaces"), object: nil)
    }
    
    func placesAPIDidReceiveErrorForPlaceType(error: Error, placeType: String) {
        print("Error getting places for type \(placeType)")
    }
}


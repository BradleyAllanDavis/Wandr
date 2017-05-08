//
//  PlacesAPISearch.swift
//  TravelApp
//
//  Created by Richard Wollack on 4/2/17.
//  Copyright © 2017 Scott Franklin. All rights reserved.
//

import UIKit
import GooglePlaces

typealias PlacesTypeDownloadProgress = (_ data: Dictionary<String, AnyObject>?, _ error: Error?) -> Void

protocol PlacesAPISearchResultUpdater: class {
    func didReceivePlacesFromAPI(places: [Dictionary<String, AnyObject>])
    func placesAPIDidReceiveErrorForPlaceType(error: Error, placeType: String)
}

protocol GMSPlaceRequestDelegate {
    func didReceiveGMSPlace(place: GMSPlace)
    func gmsPlaceDidReceiveError(error: Error)
}

class PlacesAPISearch: NSObject {
    var resultsUpdaterDelegate: PlacesAPISearchResultUpdater?
    var gmsPlaceDelegate: GMSPlaceRequestDelegate?
    
    //TODO: these will get replaced with types from the tagPreference.plist
    //    var types = ["bar"]
    
    public func requestPlacesByType(location: CLLocationCoordinate2D, searchRadius: Int, types: [String]) {
        let downloadGroup = DispatchGroup()
        var placesArray = [Dictionary<String, AnyObject>]()
        
        for type in types {
            downloadGroup.enter()
            
            searchGooglePlacesWebAPI(location: location, type: type, searchRadius: searchRadius, completion: {(data, error) in
                if let error = error {
                    self.resultsUpdaterDelegate?.placesAPIDidReceiveErrorForPlaceType(error: error, placeType: type)
                }
                
                if let data = data {
//                    PlaceStore.shared.nextPageTokens[type] = data["next_page_toke"] as? String
                    let placesDictArray = data["results"] as! [Dictionary<String, AnyObject>]
                    
                    if data.index(forKey: "next_page_token") != nil {
                        if let nextPageToken = data["next_page_token"] as? String {
                            PlaceStore.shared.nextPageTokens[type] = nextPageToken
                        }
                    }
                    
                    //prevent duplicates from showing up in different types
                    for place in placesDictArray {
                        let placeId = place["place_id"] as! String
                        
                        if !PlaceStore.shared.currentPlaceIds.contains(placeId) {
                            placesArray.append(place)
                            PlaceStore.shared.currentPlaceIds.append(placeId)
                        }
                    }
                }
                
                downloadGroup.leave()
            })
        }
        
        downloadGroup.notify(queue: DispatchQueue.main) {
            print("Finished downloading for all place types")
            self.resultsUpdaterDelegate?.didReceivePlacesFromAPI(places: placesArray)
        }
    }
    
    private func searchGooglePlacesWebAPI(location: CLLocationCoordinate2D,
                                          type: String,
                                          searchRadius: Int,
                                          completion: @escaping PlacesTypeDownloadProgress) {
        guard let key = getPlacesAPIKey()! as String? else {
            print("Error searching google places")
            return
        }
        
        let keyString = "&key=" + key
        let base = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
        var query: String?
        
        if PlaceStore.shared.apiSearchMode == .initial {
            let locationString = "&location=" + location.latitude.description + "," + location.longitude.description
            let radiusString = "&radius=" + searchRadius.description
            let typeString = "&type=" + type
            query = base + locationString + radiusString + typeString + keyString
        } else {
            if let token = PlaceStore.shared.nextPageTokens[type] {
                query = base + "pagetoken=" + token + keyString
            }
        }
        
        if query == nil {
            print("no more results for that type")
            return
        }
        
        let url = URL(string: query!)
        let task = URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            var json = Dictionary<String, AnyObject>()
            
            if let data = data {
                json = try! JSONSerialization.jsonObject(with: data, options: []) as! Dictionary<String, AnyObject>
            }
            
            completion(json, error)
        })
        
        task.resume()
    }
    
    func getGMSPlacesById(placeIds: [String]) {
        for placeId in placeIds {
            GMSPlacesClient.shared().lookUpPlaceID(placeId, callback: { (place, error) -> Void in
                if let error = error {
                    print("lookup place id query error: \(error.localizedDescription)")
                    self.gmsPlaceDelegate?.gmsPlaceDidReceiveError(error: error)
                    return
                }
                
                guard let place = place else { return }
                
                self.gmsPlaceDelegate?.didReceiveGMSPlace(place: place)
            })
        }
    }
    
    private func getPlacesAPIKey() -> String? {
        if let configPath = Bundle.main.url(forResource: "APIConfig", withExtension: "plist") {
            do {
                let data = try Data(contentsOf: configPath)
                let dict = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as! [String:Any]
                
                if let key = dict["PlacesAPIKey"] as? String {
                    return key
                } else {
                    print("Config file present but no api key found")
                    return nil
                }
                
            } catch {
                print("Error loading api config plist")
                return nil
            }
        }
        
        return nil
    }
}

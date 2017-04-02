//
//  PlacesAPISearch.swift
//  TravelApp
//
//  Created by Richard Wollack on 4/2/17.
//  Copyright © 2017 Scott Franklin. All rights reserved.
//

import UIKit
import GooglePlaces

class PlacesAPISearch: NSObject {
    private func searchGooglePlacesWebAPI(cityPlace: GMSPlace) {
        guard let key = getPlacesAPIKey()! as String? else {
            print("Error searching google places")
            return
        }
        
        let base = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
        
        let latitude: String  = cityPlace.coordinate.latitude.description
        let longitude: String = cityPlace.coordinate.longitude.description
        let radius = 40233.6
        
        let url = URL(string: base + "&location=" + latitude + "," + longitude + "&key=" + key)
        
        let task = URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            guard error == nil else { return }
            
            if let data = data {
                let json = try! JSONSerialization.jsonObject(with: data, options: [])
                print(json)
            }
        })
        
        task.resume()
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

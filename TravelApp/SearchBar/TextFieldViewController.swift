//
//  TextFieldViewController.swift
//  TravelApp
//
//  Created by Richard Wollack on 3/13/17.
//  Copyright © 2017 Scott Franklin. All rights reserved.
//

import UIKit
import MapKit
import GooglePlaces

class TextFieldViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var searchField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard(gesture:)))
        view.addGestureRecognizer(tapGesture)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func hideKeyboard(gesture: UIGestureRecognizer) {
        searchField.resignFirstResponder()
    }
    
    @IBAction func googleSearch(_ sender: Any) {
        searchField.resignFirstResponder()
        searchGooglePlacesWebAPI(searchTerm: searchField.text!)
    }
    
    
    @IBAction func mkLocalSearch(_ sender: Any) {
        searchField.resignFirstResponder()
        searchWithAppleAPI(searchTerm: searchField.text!)
    }
    
    @IBAction func googleAutocompleteSearch(_ sender: Any) {
        searchField.resignFirstResponder()
        searchGoogleAutocompleteAPI(searchTerm: searchField.text!)
    }
    
    @IBAction func dismissView(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchGooglePlacesWebAPI(searchTerm: textField.text!)
        return true
    }
    
    private func searchWithAppleAPI(searchTerm: String) {
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchField.text
        
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            guard let response = response else {
                print("Search error: \(error)")
                return
            }
            
            print("Found: \(response.mapItems.count) items")
            
            for item in response.mapItems {
                print(item)
            }
        }
    }
    
    private func searchGoogleAutocompleteAPI(searchTerm: String) {
        let placesClient = GMSPlacesClient()
        let filter = GMSAutocompleteFilter()
        filter.type = .establishment
        placesClient.autocompleteQuery(searchTerm, bounds: nil, filter: filter, callback: {(results, error) -> Void in
            
            if let error = error {
                print("Autocomplete error \(error)")
                return
            }
            
            if let results = results {
                for result in results {
                    print("Result \(result.attributedPrimaryText) with placeID \(result.placeID)")
                }
            }
        })
    }
    
    private func searchGooglePlacesWebAPI(searchTerm: String) {
        guard let key = getPlacesAPIKey()! as String? else {
            print("Error searching google places")
            return
        }
        
        let base = "https://maps.googleapis.com/maps/api/place/textsearch/json?query="
        let query = searchTerm.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
        let url = URL(string: base + query + "&key=" + key)
        
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

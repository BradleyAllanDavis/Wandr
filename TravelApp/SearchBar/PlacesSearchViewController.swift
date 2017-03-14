//
//  PlacesSearchViewController.swift
//  TravelApp
//
//  Created by Richard Wollack on 3/11/17.
//  Copyright © 2017 Scott Franklin. All rights reserved.
//

import UIKit
import GooglePlaces

class PlacesSearchViewController: UIViewController, UISearchBarDelegate {
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let subView = UIView(frame: CGRect(x: 0, y: 40.0, width: view.frame.size.width, height: 45.0))
        
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        searchController?.searchBar.autoresizingMask = .flexibleWidth
        
        subView.addSubview((searchController?.searchBar)!)
        subView.autoresizingMask = .flexibleWidth
        view.addSubview(subView)
        
        searchController?.searchBar.sizeToFit()
        searchController?.hidesNavigationBarDuringPresentation = false
        
        definesPresentationContext = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismissView(_ sender: Any) {
        dismiss(animated: true, completion: {
            
        })
    }
    
}

extension PlacesSearchViewController: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        searchController?.isActive = false
        // Do something with the selected place.
        print("Place name: \(place.name)")
        print("Place address: \(place.formattedAddress)")
        print("Place attributions: \(place.attributions)")
    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: Error){
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}

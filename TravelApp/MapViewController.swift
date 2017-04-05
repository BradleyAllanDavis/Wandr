//
//  MapViewController.swift
//  TravelApp
//
//  Created by Macbook on 3/9/17.
//  Copyright © 2017 Scott Franklin. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import GooglePlaces
class MapViewController: UIViewController, MKMapViewDelegate, LocationServiceDelegate
{
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var resultViewController = GMSAutocompleteResultsViewController()
    var searchController: UISearchController?
    let apiSearch = PlacesAPISearch()
    
    //store places as array of dictionaries for now...
    var currentPlaces = [Dictionary<String, AnyObject>]()
    
    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            mapView.mapType = .standard
            mapView.delegate = self
            mapView.showsUserLocation = true
        }
    }
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        LocationService.singleton.startUpdatingLocation()
        let coordinateRegion = MKCoordinateRegionMakeWithDistance((LocationService.singleton.currentLocation?.coordinate)!, 4000, 4000)
        mapView.setRegion(coordinateRegion, animated: true)
        
        
        let subView = UIView(frame: CGRect(x: 0, y: 22.0, width: UIScreen.main.bounds.size.width, height: 45.0))
        let filter = GMSAutocompleteFilter()
        
        filter.type = .city
        
        apiSearch.resultsUpdaterDelegate = self
        
        resultViewController.delegate = self
        resultViewController.autocompleteFilter = filter
        
        searchController = UISearchController(searchResultsController: resultViewController)
        searchController?.searchResultsUpdater = resultViewController
        searchController?.dimsBackgroundDuringPresentation = true
        searchController?.searchBar.autoresizingMask = .flexibleWidth
        
        subView.addSubview(searchController!.searchBar)
        subView.autoresizingMask = .flexibleWidth
        
        view.addSubview(subView)
        definesPresentationContext = true
    }
    
    // Dispose of any resources that can be recreated
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    
    // LocationService delegate methods
    func tracingLocation(currentLocation: CLLocation) {}
    func tracingLocationDidFailWithError(error: NSError) {}
}

extension MapViewController: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        searchController?.isActive = false
        
        // Update map to focus on searched location
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(place.coordinate, 4000, 4000)
        mapView.setRegion(coordinateRegion, animated: true)
        
        //starts the request for places nearby the selected location
        apiSearch.requestPlacesByType(location: place.coordinate, searchRadius: 40233)
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

extension MapViewController: PlacesAPISearchResultUpdater {
    func didReceivePlacesFromAPI(places: [Dictionary<String, AnyObject>]) {
        //do something with places
        currentPlaces = places
        dump(places)
    }
    
    func placesAPIDidReceiveErrorForPlaceType(error: Error, placeType: String) {
        print("Error getting places for type \(placeType)")
    }
}

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
    
    var resultViewController = CitySearchResultsViewController()
    var searchController: UISearchController?
    
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
        var currentLocation = LocationService.singleton.currentLocation
        
        let subView = UIView(frame: CGRect(x: 0, y: 22.0, width: UIScreen.main.bounds.size.width, height: 45.0))
        
        resultViewController.delegate = self
        
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

extension MapViewController: CitySearchResultsDelegate {
    func didSelectLocation(resultsController: CitySearchResultsViewController, selectedCity: GMSPlace) {
        print("Selected City \(selectedCity)")
    }
}

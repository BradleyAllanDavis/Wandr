//
//  Page1ViewController.swift
//  TravelApp
//
//  Created by Macbook on 4/23/17.
//  Copyright © 2017 Scott Franklin. All rights reserved.
//

import UIKit
import MapKit

class Page1ViewController: UIViewController, MKMapViewDelegate, LocationServiceDelegate {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            mapView.mapType = .standard
            mapView.delegate = self
            mapView.showsUserLocation = true
        }
    }

    let locationService = LocationService.singleton
    
    //# MARK: - LocationService delegate methods
    func tracingLocation(currentLocation: CLLocation) {}
    func tracingLocationDidFailWithError(error: NSError) {}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Zoom to current location
        locationService.startUpdatingLocation()
        let lat: CLLocationDegrees
        let long: CLLocationDegrees
        
        if let currentLocation = locationService.locationManager?.location {
            lat = currentLocation.coordinate.latitude
            long = currentLocation.coordinate.longitude
        } else {
            // default to Madison if location services are off
            lat = CLLocationDegrees(43.0731)
            long = CLLocationDegrees(-89.4012)
        }
        
        let center = CLLocationCoordinate2D(latitude: lat, longitude: long)
        let span = MKCoordinateSpanMake(0.075, 0.075)
        let region = MKCoordinateRegion(center: center, span: span)
        
        mapView.setRegion(region, animated: true)

        print("view did load")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

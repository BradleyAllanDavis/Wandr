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

class MapViewController: UIViewController, MKMapViewDelegate, LocationServiceDelegate
{
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
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
        //var currentLocation = LocationService.sharedInstance.currentLocation
        
    }
    
    // Dispose of any resources that can be recreated
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    
    // LocationService delegate methods
    func tracingLocation(currentLocation: CLLocation){}
    func tracingLocationDidFailWithError(error: NSError) {}
}

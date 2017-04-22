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

class MapViewController: UIViewController, MKMapViewDelegate, LocationServiceDelegate, UIPopoverPresentationControllerDelegate
{
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var searchResultViewController = GMSAutocompleteResultsViewController()
    var tagPreferences = [String: Bool]()
    @IBOutlet weak var optionsButton: UIButton!
    
    lazy var searchController: UISearchController = ({
        [unowned self] in
        let controller = TravelSearchController(searchResultsController: self.searchResultViewController)
        
        controller.delegate = self
        controller.searchResultsUpdater = self.searchResultViewController
        controller.dimsBackgroundDuringPresentation = false
        controller.searchBar.placeholder = "Where To?"
        
        return controller
    })()
    
    var navBarView: TravelNavBarView!
    var slideView: SlideUpView!
    
    //store places as array of dictionaries for now...
    var currentPlaces = [Dictionary<String, AnyObject>]()
    
    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            mapView.mapType = .standard
            mapView.delegate = self
            mapView.showsUserLocation = true
        }
    }
    
    let locationService = LocationService.singleton
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        definesPresentationContext = true
        
        // Zoom to current location
        locationService.startUpdatingLocation()
        let currentLocation = locationService.locationManager?.location
        let lat = currentLocation?.coordinate.latitude
        let long = currentLocation?.coordinate.longitude
        let center = CLLocationCoordinate2D(latitude: lat!, longitude: long!)
        let span = MKCoordinateSpanMake(0.075, 0.075)
        let region = MKCoordinateRegion(center: center, span: span)
        mapView.setRegion(region, animated: true)
        
        dump(tagPreferences)
        setupSearchBar()
        
        let effect = UIBlurEffect(style: .dark)
        slideView = SlideUpView(effect: effect)
        mapView.insertSubview(slideView, aboveSubview: optionsButton)
        
        //Register notifications
        NotificationCenter.default.addObserver(self, selector: #selector(updatePlaces(notification:)), name: Notification.Name(rawValue: "ReceivedNewNearbyPlaces"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(nearbyFocusedPlaceChanged(notification:)), name: Notification.Name(rawValue: "NearbyFocusedPlaceChanged"), object: nil)
        
        //Search for places using current location
        updateUserTagPreferences()
        PlaceStore.shared.updateCurrentPlaces(with: center, searchRadius: 4000)
    }
    
    // Changes the focus of the map when scrolling through the CollectionView
    func nearbyFocusedPlaceChanged(notification: Notification) {
        let selectedIndex = PlaceStore.shared.currentNearbyFocusedPlaceIndex
        let placeLoc = PlaceStore.shared.nearbyPlaces[selectedIndex]["geometry"]!["location"] as! Dictionary<String, AnyObject>
        let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(placeLoc["lat"] as! CLLocationDegrees, placeLoc["lng"] as! CLLocationDegrees)
        let span = MKCoordinateSpanMake(0.025, 0.025)
        let region = MKCoordinateRegion(center: location, span: span)
        
        mapView.setRegion(region, animated: true)
        
        let currentPlaceName = PlaceStore.shared.getCurrentFocusedPlace()["name"] as? String
        
        // Show annotation call out
        for annotation in mapView.annotations {
            if annotation.title as? String  == currentPlaceName {
                mapView.selectAnnotation(annotation, animated: true)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMapSettings" {
            let popoverViewController = segue.destination
            popoverViewController.popoverPresentationController?.delegate = self
            
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    // Dispose of any resources that can be recreated
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }    
    
    //# MARK: - LocationService delegate methods
    func tracingLocation(currentLocation: CLLocation) {}
    func tracingLocationDidFailWithError(error: NSError) {}
    
    //# MARK: - Methods for navigation to tag and cart views
    func transitionToPreferenceView() -> Void {
        let storyboard = UIStoryboard(name: "Tag", bundle: .main)
        let vc = storyboard.instantiateInitialViewController()
        present(vc!, animated: true, completion: nil)
    }
    
    func transitionToCartView() -> Void {
        let storyboard = UIStoryboard(name: "Cart", bundle: .main)
        let vc = storyboard.instantiateInitialViewController()
        present(vc!, animated: true, completion: nil)
    }
    
    func setupSearchBar() {
        let filter = GMSAutocompleteFilter()
        filter.type = .city
        
        searchResultViewController.autocompleteFilter = filter
        searchResultViewController.delegate = self
        navBarView = TravelNavBarView(
            frame: CGRect(x: 15, y: 25.0, width: UIScreen.main.bounds.size.width - 30, height: 45.0),
            searchBar: searchController.searchBar,
            navHandler: self,
            preferenceSelector: #selector(transitionToPreferenceView),
            cartSelector: #selector(transitionToCartView)
        )
        searchController.searchBar.delegate = navBarView
        
        view.addSubview(navBarView)
    }
    
    func updatePlaces(notification: Notification) {
        currentPlaces = PlaceStore.shared.nearbyPlaces
        
        // Add place annotations to map
        for place in PlaceStore.shared.nearbyPlaces {
            let placeLoc = place["geometry"]!["location"] as! Dictionary<String, AnyObject>
            let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(placeLoc["lat"] as! CLLocationDegrees, placeLoc["lng"] as! CLLocationDegrees)
            let annotation = MKPointAnnotation()
            annotation.coordinate = location
            annotation.title = place["name"] as? String
            mapView.addAnnotation(annotation)
        }
    }
    
    func updateUserTagPreferences() {
        // Update types for API search if preferences are set
        var types = [String]()
        for type in tagPreferences {
            if type.value {
                types.append(type.key)
            }
        }
        
        if !types.isEmpty {
            dump(types)
            PlaceStore.shared.userSelectedPlaceTypes = types
        }
    }
}

//# MARK: - UISearchResultsUpdating methods

extension MapViewController: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        searchController.dismiss(animated: true, completion: {
            self.navBarView.transitionToOrignialState()
            self.navBarView.searchBar.searchTextField.text = place.formattedAddress
        })
        
        // Update map to focus on searched location
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(place.coordinate, 5000, 5000)
        mapView.setRegion(coordinateRegion, animated: true)
        
        updateUserTagPreferences()
            
        //starts the request for places nearby the selected location
        PlaceStore.shared.updateCurrentPlaces(with: place.coordinate, searchRadius: 4000)
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

//<<<<<<< HEAD
////# MARK: - UISearchControllerDelegate methodes
//=======
////# MARK: - PlacesAPISearchUpdater methods
//
//extension MapViewController: PlacesAPISearchResultUpdater {
//    func didReceivePlacesFromAPI(places: [Dictionary<String, AnyObject>]) {
//        //do something with places
//        currentPlaces = places
//        dump(places)
//        
//        // Add place annotations to map
//        for place in places {
//            let placeLoc = place["geometry"]!["location"] as! Dictionary<String, AnyObject>
//            let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(placeLoc["lat"] as! CLLocationDegrees, placeLoc["lng"] as! CLLocationDegrees)
//            let annotation = MKPointAnnotation()
//            annotation.coordinate = location
//            annotation.title = place["name"] as? String
//            mapView.addAnnotation(annotation)
//        }
//    }
//    
//    func placesAPIDidReceiveErrorForPlaceType(error: Error, placeType: String) {
//        print("Error getting places for type \(placeType)")
//    }
//}

//# MARK: - UISearchControllerDelegate methods
extension MapViewController: UISearchControllerDelegate {
    func didDismissSearchController(_ searchController: UISearchController) {
        searchController.searchBar.frame = navBarView.originalSearchBarFrame
    }
}

//# MARK: - MKMapView extension

extension MKMapView {
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        //reposition the compass so it's not under the search bar
        let compassView = self.value(forKey: "compassView") as! UIView
        compassView.frame = CGRect(x: compassView.frame.origin.x, y: 75, width: 36, height: 36)
    }
}

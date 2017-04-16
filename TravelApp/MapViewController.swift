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
    var searchResultViewController = GMSAutocompleteResultsViewController()
    var tagPreferences = [String: Bool]()
    
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
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        definesPresentationContext = true
        LocationService.singleton.startUpdatingLocation()
        //var currentLocation = LocationService.sharedInstance.currentLocation
        
        dump(tagPreferences)
        setupSearchBar()
        
        let effect = UIBlurEffect(style: .dark)
        slideView = SlideUpView(effect: effect)
        mapView.addSubview(slideView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updatePlaces(notification:)), name: Notification.Name(rawValue: "ReceivedNewPlaces"), object: nil)
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
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(place.coordinate, 4000, 4000)
        mapView.setRegion(coordinateRegion, animated: true)
        
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

//# MARK: - UISearchControllerDelegate methodes
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

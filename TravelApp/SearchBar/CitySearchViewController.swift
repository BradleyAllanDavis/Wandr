//
//  LocalSearchViewController.swift
//  TravelApp
//
//  Created by Richard Wollack on 3/13/17.
//  Copyright © 2017 Scott Franklin. All rights reserved.
//

import UIKit
import GooglePlaces

class CitySearchViewController: UIViewController {
    var searchResults = [GMSPlace]()
    var selection: NSString?
    var resultViewController = CitySearchResultsViewController()
    var searchController: UISearchController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let subView = UIView(frame: CGRect(x: 0, y: 40.0, width: view.frame.size.width, height: 45.0))
        
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismiss(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension CitySearchViewController: CitySearchResultsDelegate {
    func didSelectLocation(resultsController: CitySearchResultsViewController, selectedCity: GMSPlace) {
        print("Selected City \(selectedCity)")
    }
}

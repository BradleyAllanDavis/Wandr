//
//  LocalSearchViewController.swift
//  TravelApp
//
//  Created by Richard Wollack on 3/13/17.
//  Copyright © 2017 Scott Franklin. All rights reserved.
//

import UIKit
import MapKit

class LocalSearchViewController: UIViewController, UISearchControllerDelegate, UISearchBarDelegate {
    var autoCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    var resultViewController = SearchResultsViewController()
    var searchController: UISearchController?
    var selection: MKLocalSearchCompletion?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let subView = UIView(frame: CGRect(x: 0, y: 40.0, width: view.frame.size.width, height: 45.0))
        
        autoCompleter.delegate = self
        
        searchController = UISearchController(searchResultsController: resultViewController)
        searchController?.searchResultsUpdater = self
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

extension LocalSearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        autoCompleter.queryFragment = searchController.searchBar.text!
    }
}

extension LocalSearchViewController: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        resultViewController.searchResults = completer.results
        resultViewController.tableView.reloadData()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Error getting search results")
    }
}


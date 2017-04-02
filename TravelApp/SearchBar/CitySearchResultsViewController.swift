//
//  SearchResultsViewController.swift
//  test-places-api
//
//  Created by Richard Wollack on 3/13/17.
//  Copyright © 2017 Richard Wollack. All rights reserved.
//

import UIKit
import GooglePlaces

protocol CitySearchResultsDelegate: class {
    func didSelectLocation(resultsController: CitySearchResultsViewController, selectedCity: GMSPlace)
}

class CitySearchResultsViewController: UITableViewController {
    weak var delegate: CitySearchResultsDelegate?
    var searchResults = [GMSAutocompletePrediction]()
    let placesClient = GMSPlacesClient()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupFooterView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupFooterView() {
        let googleImage = UIImage(named: "powered_by_google_on_white@2x.png")
        let footerImageView = UIImageView()
        let footerView = UIView()
        
        footerImageView.image = googleImage
        footerImageView.frame = CGRect(x: 0.0, y: 0.0, width: (googleImage?.size.width)!, height: (googleImage?.size.height)!)
        footerView.frame = CGRect(x: 0.0, y: 0.0, width: tableView.frame.width, height: (googleImage?.size.height)! + 10.0)
        footerView.addSubview(footerImageView)
        footerImageView.center = footerView.center
        
        tableView.register(UINib(nibName: "SearchResultsTableViewCell", bundle: nil), forCellReuseIdentifier: "SearchCell")
        tableView.tableFooterView = footerView
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell") as! SearchResultsTableViewCell
        
        cell.titleLabel.attributedText = searchResults[indexPath.row].attributedPrimaryText
        cell.addressLabel.attributedText = searchResults[indexPath.row].attributedSecondaryText
        cell.completionItem = searchResults[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        placesClient.lookUpPlaceID(searchResults[indexPath.row].placeID!, callback: {(result, error) -> Void in
            if let error = error {
                print("Error getting place \(error)")
            }
            
            if let result = result {
                self.delegate?.didSelectLocation(resultsController: self, selectedCity: result)
            }
        })
        
        let parentViewController = presentingViewController as! CitySearchViewController
        parentViewController.selection = searchResults[indexPath.row].placeID as NSString?
        
        dismiss(animated: true, completion: nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74.0
    }
}

extension CitySearchResultsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let filter = GMSAutocompleteFilter()
        filter.type = .city
        
        if let searchString = searchController.searchBar.text {
            guard searchString.characters.count > 0 else { return }
            
            placesClient.autocompleteQuery(
                searchString,
                bounds: nil,
                filter: filter,
                callback: {(results, error) -> Void in
                    
                    if let error = error {
                        print("Autocomplete error \(error)")
                        return
                    }
                    
                    if let results = results {
                        self.searchResults = results
                        self.tableView.reloadData()
                    }
            })
        }
    }
}

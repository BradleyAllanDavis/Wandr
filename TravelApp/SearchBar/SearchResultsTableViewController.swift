//
//  SearchResultsViewController.swift
//  test-places-api
//
//  Created by Richard Wollack on 3/13/17.
//  Copyright © 2017 Richard Wollack. All rights reserved.
//

import UIKit
import MapKit

class SearchResultsViewController: UITableViewController {
    var searchResults = [MKLocalSearchCompletion]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "SearchResultsTableViewCell", bundle: nil), forCellReuseIdentifier: "SearchCell")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell") as! SearchResultsTableViewCell
        cell.titleLabel.text = searchResults[indexPath.row].title
        cell.completionItem = searchResults[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let parentViewController = presentingViewController as! LocalSearchViewController
        parentViewController.selection = searchResults[indexPath.row]
        dismiss(animated: true, completion: nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }    
}

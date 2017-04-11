//
//  TravelSearchControllerViewController.swift
//  TravelApp
//
//  Created by Richard Wollack on 4/5/17.
//  Copyright © 2017 Scott Franklin. All rights reserved.
//

import UIKit

class TravelSearchController: UISearchController, UISearchControllerDelegate {
    
    lazy var travelSearchBar = TravelSearchBar(frame: .zero)
    
    override public var searchBar: UISearchBar {
        get {
            return travelSearchBar
        }
    }
}

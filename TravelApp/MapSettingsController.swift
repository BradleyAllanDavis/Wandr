//
//  MapSettingsController.swift
//  TravelApp
//
//  Created by Bradley on 4/23/17.
//  Copyright © 2017 Scott Franklin. All rights reserved.
//

import UIKit

class MapSettingsController: UIViewController
{
    @IBOutlet weak var mapType: UISegmentedControl!
    
    @IBAction func changeMapType(_ sender: UISegmentedControl!) {
        let vc = self.presentingViewController as! MapViewController
        switch (sender.selectedSegmentIndex) {
        case 0:
            vc.mapView.mapType = .standard
        case 1:
            vc.mapView.mapType = .satellite
        default:
            vc.mapView.mapType = .hybrid
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Set segmented control corresponding map type
        let vc = self.presentingViewController as! MapViewController
        switch (vc.mapView.mapType) {
        case .standard:
            self.mapType.selectedSegmentIndex = 0
        case .satellite:
            self.mapType.selectedSegmentIndex = 1
        default:
            self.mapType.selectedSegmentIndex = 2
        }
    }
}

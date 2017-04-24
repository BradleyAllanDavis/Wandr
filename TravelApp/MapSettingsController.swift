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
    @IBAction func changeMapType(_ sender: UISegmentedControl!) {
        print("segmentedControlAction")
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
    }
}

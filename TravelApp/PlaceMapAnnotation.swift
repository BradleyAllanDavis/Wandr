//
//  PlaceMapAnnotation.swift
//  TravelApp
//
//  Created by Richard Wollack on 5/5/17.
//  Copyright © 2017 Scott Franklin. All rights reserved.
//

import UIKit
import MapKit

class PlaceMapAnnotation: NSObject, MKAnnotation {
    var placeName: String!
    var placeId: String!
    var myTitle: String
    
    var myCoordinate: CLLocationCoordinate2D
    
    init(myCoordinate: CLLocationCoordinate2D, title: String) {
        self.myTitle = title
        self.myCoordinate = myCoordinate
    }
    
    var coordinate: CLLocationCoordinate2D {
        return myCoordinate
    }
    
    var title: String? {
        return myTitle
    }
}

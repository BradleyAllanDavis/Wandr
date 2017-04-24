//
//  PlaceDetailViewController.swift
//  TravelApp
//
//  Created by Macbook on 4/11/17.
//  Copyright © 2017 Scott Franklin. All rights reserved.
//

import UIKit

class PlaceDetailController: UIViewController
{
    var currentPlace: Dictionary<String, Any>?
    
//    @IBOutlet weak var titleLabel: UILabel!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

//
//  TravelSearchBar.swift
//  TravelApp
//
//  Created by Richard Wollack on 4/5/17.
//  Copyright © 2017 Scott Franklin. All rights reserved.
//

import UIKit

class TravelSearchBar: UISearchBar {
    var searchTextField: UITextField!
    var searchCancelButton: UIButton!
    var font: UIFont!
    var originalTextFrame: CGRect!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupProps()
        searchBarStyle = .prominent
        isTranslucent = true
        barTintColor = UIColor.clear
        backgroundImage = UIImage()
        clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setupProps() -> Void {
        let color = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        let cancelFont = UIFont(name: "Avenir", size: 16)
        let searchFont = UIFont(name: "Avenir", size: 14)
        
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes(
            [NSForegroundColorAttributeName: color,
             NSFontAttributeName: cancelFont!],
            for: .normal
        )
        
        searchTextField = self.value(forKey: "searchField") as! UITextField
        searchTextField.backgroundColor = .clear
        searchTextField.tintColor = .black
        searchTextField.clearButtonMode = .whileEditing
        searchTextField.font = searchFont
    }
}

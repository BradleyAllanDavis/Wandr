//
//  CartCollectionReusableView.swift
//  
//
//  Created by Richard Wollack on 5/4/17.
//
//

import UIKit

class CartCollectionReusableView: UICollectionReusableView {

    @IBOutlet weak var headerTitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBAction func redoSearchInCity(_ sender: Any) {
        print("Search from cart header")
    }
    
}

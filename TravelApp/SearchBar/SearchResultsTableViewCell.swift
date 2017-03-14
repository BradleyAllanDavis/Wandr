//
//  SearchResultsTableViewCell.swift
//  TravelApp
//
//  Created by Richard Wollack on 3/13/17.
//  Copyright © 2017 Scott Franklin. All rights reserved.
//

import UIKit
import MapKit

class SearchResultsTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    var completionItem: MKLocalSearchCompletion?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

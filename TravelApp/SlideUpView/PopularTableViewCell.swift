//
//  PopularTableViewCell.swift
//  TravelApp
//
//  Created by Richard Wollack on 4/14/17.
//  Copyright © 2017 Scott Franklin. All rights reserved.
//

import UIKit
import Cosmos

class PopularTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var starLabel: CosmosView!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var vicinityLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        starLabel.settings.fillMode = .precise
        starLabel.backgroundColor = .none
        selectionStyle = .none
        thumbnailImageView.bounds.size.width = thumbnailImageView.bounds.size.height
        thumbnailImageView.layer.cornerRadius = thumbnailImageView.bounds.size.width / 2
        thumbnailImageView.layer.masksToBounds = true
        thumbnailImageView.layer.borderColor = UIColor.white.cgColor
        thumbnailImageView.layer.borderWidth = 1.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

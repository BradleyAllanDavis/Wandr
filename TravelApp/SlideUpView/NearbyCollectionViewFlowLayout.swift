//
//  NearbyCollectionViewFlowLayout.swift
//  TravelApp
//
//  Created by Richard Wollack on 4/15/17.
//  Copyright © 2017 Scott Franklin. All rights reserved.
//

import UIKit

class NearbyCollectionViewFlowLayout: UICollectionViewFlowLayout {
    override init() {
        super.init()
        
        self.itemSize = CGSize(width: 75.0, height: 75.0);
        self.minimumInteritemSpacing = 10.0;
        self.minimumLineSpacing = 10.0;
        self.scrollDirection = .horizontal
        self.sectionInset = UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0);
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}

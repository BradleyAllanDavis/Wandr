//
//  NearbyCollectionViewFlowLayout.swift
//  TravelApp
//
//  Created by Richard Wollack on 4/20/17.
//  Copyright © 2017 Scott Franklin. All rights reserved.
//

import UIKit

class NearbyCollectionViewFlowLayout: UICollectionViewFlowLayout {
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        var offsetAdjustment:CGFloat = CGFloat(MAXFLOAT)
        let horizontalCenter = proposedContentOffset.x + ((collectionView?.bounds.width)! / 2.0)
        let targetRect = CGRect(x: proposedContentOffset.x, y: 0.0, width: (collectionView?.bounds.size.width)!, height: (collectionView?.bounds.size.height)!)
        let attributesArray = super.layoutAttributesForElements(in: targetRect)
        
        for attribute in attributesArray! {
            let itemHorizontalCenter = attribute.center.x
            
            if (abs(itemHorizontalCenter - horizontalCenter) < abs(offsetAdjustment)) {
                offsetAdjustment = itemHorizontalCenter - horizontalCenter;
            }
        }
        
        return CGPoint(x: proposedContentOffset.x + offsetAdjustment, y: proposedContentOffset.y)
    }
}

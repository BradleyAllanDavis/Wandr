//
//  TravelNavBarView.swift
//  TravelApp
//
//  Created by Richard Wollack on 4/6/17.
//  Copyright © 2017 Scott Franklin. All rights reserved.
//

import UIKit
import GooglePlaces

class TravelNavBarView: UIVisualEffectView {
    private var originalCartButtonFrame: CGRect!
    private var animatedCartButtonFrame: CGRect!
    private var animatedPrefButtonFrame: CGRect!
    private var originalPrefButtonFrame: CGRect!
    private var animationDuration = 0.25
    private var buttonHeight: CGFloat = 20.0
    private var preferenceButton: UIButton!
    private var cartButton: UIButton!
    
    var searchBar: TravelSearchBar!
    var originalSearchBarFrame: CGRect!
    
    convenience init(frame: CGRect,
                     searchBar: UISearchBar,
                     navHandler: AnyObject,
                     preferenceSelector: Selector,
                     cartSelector: Selector) {
        self.init()
        
        let buttonOffset = (frame.size.height - buttonHeight) / 2
        let blurEffect = UIBlurEffect(style: .light)
        
        //store frames for animations
        originalSearchBarFrame = CGRect(x: 30.0, y: 0.0, width: frame.size.width - 60.0, height: frame.size.height)
        originalCartButtonFrame = CGRect(x: frame.size.width - 30.0, y: buttonOffset, width: buttonHeight, height: buttonHeight)
        animatedCartButtonFrame = CGRect(x: UIScreen.main.bounds.size.width, y: buttonOffset, width: buttonHeight, height: buttonHeight)
        originalPrefButtonFrame = CGRect(x: 5.0, y: buttonOffset, width: buttonHeight, height: buttonHeight)
        animatedPrefButtonFrame = CGRect(x: -50.0, y: buttonOffset, width: buttonHeight, height: buttonHeight)
        
        self.searchBar = searchBar as! TravelSearchBar
        self.searchBar.frame = originalSearchBarFrame
        self.frame = frame
        
        effect = blurEffect
        
        preferenceButton = UIButton(frame: originalPrefButtonFrame)
        preferenceButton.setBackgroundImage(#imageLiteral(resourceName: "gear-7"), for: .normal)
        preferenceButton.addTarget(navHandler, action: preferenceSelector, for: .touchUpInside)
        
        cartButton = UIButton(frame: originalCartButtonFrame)
        cartButton.setBackgroundImage(#imageLiteral(resourceName: "shopping-cart-7"), for: .normal)
        cartButton.addTarget(navHandler, action: cartSelector, for: .touchUpInside)
        
        let shadowView = UIView(frame: CGRect(x: 0.0, y: 0, width: frame.size.width, height: frame.size.height))
        shadowView.translatesAutoresizingMaskIntoConstraints = false
        shadowView.backgroundColor = UIColor.white
        shadowView.alpha = 0.2
        shadowView.layer.masksToBounds = false
        shadowView.layer.shadowOffset = CGSize(width: 2.5, height: 2.5)
        shadowView.layer.shadowOpacity = 1.0
        shadowView.layer.shadowRadius = 2.5
        
        insertSubview(shadowView, at: 0)
        addSubview(preferenceButton)
        addSubview(searchBar)
        addSubview(cartButton)
    }
    
    func transitionToOrignialState() -> Void {
        UIView.animate(withDuration: animationDuration, animations: {
            self.searchBar.searchTextField.textAlignment = .center
            self.searchBar.searchTextField.backgroundColor = .clear
            self.searchBar.frame = self.originalSearchBarFrame
            self.cartButton.frame = self.originalCartButtonFrame
            self.preferenceButton.frame = self.originalPrefButtonFrame
            self.cartButton.isHidden = false
        })
    }
    
    func transitionToSearchState() -> Void {
        UIView.animate(withDuration: animationDuration, animations: {
            self.searchBar.searchTextField.textAlignment = .left
            self.searchBar.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 45)
            self.cartButton.frame = self.animatedCartButtonFrame
            self.preferenceButton.frame = self.animatedPrefButtonFrame
            self.cartButton.isHidden = true
        })
    }
}

//#MARK: - UISearchBarDelegate methods

extension TravelNavBarView: UISearchBarDelegate {    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
        transitionToOrignialState()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
        transitionToOrignialState()
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        
        return true
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        transitionToSearchState()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.characters.count > 0 {
            self.searchBar.searchTextField.backgroundColor = .white
        } else {
            self.searchBar.searchTextField.backgroundColor = .clear
        }
    }
}

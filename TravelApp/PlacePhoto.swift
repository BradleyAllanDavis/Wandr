//
//  PlacePhoto.swift
//  TravelApp
//
//  Created by Richard Wollack on 4/16/17.
//  Copyright © 2017 Scott Franklin. All rights reserved.
//

import UIKit
import GooglePlaces

enum PhotoStatus {
    case downloaded
    case downloading
    case failed
}

typealias PhotoDownloadCompletionBlock = (_ image: UIImage?, _ error: Error?) -> Void

class PlacePhoto: NSObject {
    var status: PhotoStatus = .downloading
    var image: UIImage?
    let placeId: String
    let place: Dictionary<String, AnyObject>
    
    init(placeId: String, completion: PhotoDownloadCompletionBlock!) {
        self.placeId = placeId
        self.place = PlaceStore.shared.nearbyPlaces.filter({
            $0["place_id"] as! String == placeId
        }).first!
        
        super.init()
        self.loadFirstPhotoForPlace(downloadCompletion: completion)
    }
    
    private func loadFirstPhotoForPlace(downloadCompletion: @escaping PhotoDownloadCompletionBlock) {
        GMSPlacesClient.shared().lookUpPhotos(forPlaceID: placeId) { (photos, error) -> Void in
            if let error = error {
                // TODO: handle the error.
                print("Error: \(error.localizedDescription)")
            } else {
                if let firstPhoto = photos?.results.first {
                    self.loadImageForMetadata(photoMetadata: firstPhoto, completion: downloadCompletion)
                } else {
                    self.downloadIcon(downloadCompletion: downloadCompletion)
                }
            }
        }
    }
    
    private func loadImageForMetadata(photoMetadata: GMSPlacePhotoMetadata, completion: PhotoDownloadCompletionBlock?) {
        GMSPlacesClient.shared().loadPlacePhoto(photoMetadata, callback: {
            (photo, error) -> Void in
            if error != nil {
                self.status = .failed
            } else {
                self.status = .downloaded
                self.image = photo
            }
            
            completion?(photo, error)
            
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "AddedNewPhoto"), object: self, userInfo: ["placeId": self.placeId])
            }
        })
    }
    
    private func downloadIcon(downloadCompletion: @escaping PhotoDownloadCompletionBlock) {
        let downloadSession = URLSession(configuration: URLSessionConfiguration.ephemeral)
        let url = URL(string: place["icon"] as! String)
        let task = downloadSession.dataTask(with: url!, completionHandler: {
            data, response, error in
            if let data = data {
                self.image = UIImage(data: data)
            }
            
            if error == nil && self.image != nil {
                self.status = .downloaded
            } else {
                self.status = .failed
            }
            
            downloadCompletion(self.image, error)
            
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "AddedNewPhoto"), object: self, userInfo: ["placeId": self.placeId])
            }
        })
        
        task.resume()
    }
}

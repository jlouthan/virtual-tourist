//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Jennifer Louthan on 6/4/16.
//  Copyright © 2016 JennyLouthan. All rights reserved.
//

import UIKit
import MapKit

class PhotoAlbumViewController: UIViewController {
    
    var pin: Pin!
    
    override func viewDidLoad() {
        print("my pin is")
        print(pin.latitude)
        print(pin.longitude)
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if pin.photos.isEmpty {
            
            FlickrClient.sharedInstance().getPhotosForLatLong(pin.latitude, longitude: pin.longitude, completionHandlerForGetPhotosForLatLong: { (success, photos) in
                
                guard success == true else {
                    print("Error getting photos")
                    return
                }
                
                self.pin.photos = photos!
                
            })
        }
    }
}


//
//  Pin.swift
//  VirtualTourist
//
//  Created by Jennifer Louthan on 6/4/16.
//  Copyright © 2016 JennyLouthan. All rights reserved.
//

class Pin {
    
    //MARK: Properties
    
    let latitude: Double
    let longitude: Double
    var photos = [Photo]()
    
    //MARK Initializers
    
    init(dictionary: [String: AnyObject]) {
        latitude = dictionary["latitude"] as! Double
        longitude = dictionary["longitude"] as! Double
    }
}

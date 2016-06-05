//
//  MapAnnotation.swift
//  VirtualTourist
//
//  Created by Jennifer Louthan on 6/4/16.
//  Copyright © 2016 JennyLouthan. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class MapAnnotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var pin: Pin
    
    
    init(pin: Pin) {
        coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
        self.pin = pin
        
        super.init()
    }
}

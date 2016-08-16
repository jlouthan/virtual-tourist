//
//  Photo.swift
//  VirtualTourist
//
//  Created by Jennifer Louthan on 6/4/16.
//  Copyright © 2016 JennyLouthan. All rights reserved.
//

import UIKit
import CoreData

class Photo : NSManagedObject {
    
    @NSManaged var imageUrl: String
    @NSManaged var imageData: NSData?
    @NSManaged var pin: Pin?
    
    // Include this standard Core Data init method
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(imageUrl: String, context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.imageUrl = imageUrl
    }
}

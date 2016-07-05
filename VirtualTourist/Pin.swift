//
//  Pin.swift
//  VirtualTourist
//
//  Created by Jennifer Louthan on 6/4/16.
//  Copyright © 2016 JennyLouthan. All rights reserved.
//

import CoreData

class Pin : NSManagedObject {
    
    //MARK: Properties
    
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var photos: [Photo]
//    var photos = [Photo]()
    
    //MARK - Initializers
    
//    // Include this standard Core Data init method
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String: AnyObject], context: NSManagedObjectContext) {
        //Get the entity associated with the Pin type
        let entity = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        
        //Use the inherited init method from NSManagedObject
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        //Finally, set the properties on the model
        latitude = dictionary["latitude"] as! Double
        longitude = dictionary["longitude"] as! Double
    }
}

//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Jennifer Louthan on 6/4/16.
//  Copyright © 2016 JennyLouthan. All rights reserved.
//

import Foundation

class FlickrClient: NSObject {
    
    // shared request builder
    let requestBuilder = NetworkRequestBuilder.sharedInstance()
    
    // MARK: Helper for Creating a URL from Parameters
    
    func flickrURLFromParameters(parameters: [String:AnyObject]) -> NSURL {
        
        let components = NSURLComponents()
        components.scheme = FlickrConstants.API.APIScheme
        components.host = FlickrConstants.API.APIHost
        components.path = FlickrConstants.API.APIPath
        components.queryItems = [NSURLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.URL!
    }
    
    //MARK: Shared Instance
    class func sharedInstance() -> FlickrClient{
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        return Singleton.sharedInstance
    }
}
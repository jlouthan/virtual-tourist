//
//  FlickrConvenience.swift
//  VirtualTourist
//
//  Created by Jennifer Louthan on 6/4/16.
//  Copyright © 2016 JennyLouthan. All rights reserved.
//

import Foundation

extension FlickrClient {
    
    private func getBBoxString(lat: Double, long: Double) -> String {
        let minLong = max(long - FlickrConstants.API.SearchBBoxHalfWidth, FlickrConstants.API.SearchLonRange.0)
        let minLat = max(lat - FlickrConstants.API.SearchBBoxHalfHeight, FlickrConstants.API.SearchLatRange.0)
        let maxLong = min(long + FlickrConstants.API.SearchBBoxHalfWidth, FlickrConstants.API.SearchLonRange.1)
        let maxLat = min(lat + FlickrConstants.API.SearchBBoxHalfHeight, FlickrConstants.API.SearchLatRange.1)
        
        return "\(minLong),\(minLat),\(maxLong),\(maxLat)"
    }
    
    //MARK: GET Convenience Methods
    
    func getPhotosForLatLong(latitude: Double, longitude: Double, completionHandlerForGetPhotosForLatLong: (success: Bool, photos: [Photo]?) -> Void ) {

        let parameters = [
            FlickrConstants.ParameterKeys.BoundingBox: getBBoxString(latitude, long: longitude),
            FlickrConstants.ParameterKeys.SafeSearch: FlickrConstants.ParameterValues.UseSafeSearch,
            FlickrConstants.ParameterKeys.NoJSONCallback: FlickrConstants.ParameterValues.DisableJSONCallback,
            FlickrConstants.ParameterKeys.Method: FlickrConstants.ParameterValues.SearchMethod,
            FlickrConstants.ParameterKeys.Extras: FlickrConstants.ParameterValues.MediumURL,
            FlickrConstants.ParameterKeys.Format: FlickrConstants.ParameterValues.ResponseFormat,
            FlickrConstants.ParameterKeys.APIKey: FlickrConstants.ParameterValues.APIKey,
            FlickrConstants.ParameterKeys.PerPage: FlickrConstants.ParameterValues.NumPerPage
        ]

        
        let url = flickrURLFromParameters(parameters)
        let headers = [String: String]()
        
        requestBuilder.taskForGETMethod(url, headers: headers) { (result, error) in
            
            //TODO actually send the message if there's an error?
            func sendError() {
                completionHandlerForGetPhotosForLatLong(success: false, photos: nil)
            }
            
            guard error == nil else {
                sendError()
                return
            }
            
            guard let allPhotos = result[FlickrConstants.ResponseKeys.Photos] as? [String: AnyObject], let photos = allPhotos[FlickrConstants.ResponseKeys.Photo] as? [[String: AnyObject]] else {
//                displayError("Unexpected response JSON format")
                sendError()
                return
            }
            
            if photos.isEmpty {
//                displayError("No images found for page")
                sendError()
                return
            }
            
            var pinPhotos = [Photo]()
//            for photo in photos {
//                pinPhotos.append(Photo(imageUrl: photo[FlickrConstants.ResponseKeys.MediumURL] as! String))
//            }
            
            
            //Send the desired values to completion handler
            print(result)
            
            //If there isn't an error, always return a photos array, even if empty
            completionHandlerForGetPhotosForLatLong(success: true, photos: pinPhotos)
        }
        
    }
    
}
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
    
    @IBOutlet weak var collectionView: UICollectionView!
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if pin.photos.isEmpty {
            
            FlickrClient.sharedInstance().getPhotosForLatLong(pin.latitude, longitude: pin.longitude, completionHandlerForGetPhotosForLatLong: { success, photoDictionaries in
                
                guard success == true else {
                    print("Error getting photos")
                    return
                }
            
                for photo in photoDictionaries! {
                    let photo = Photo(imageUrl: photo[FlickrConstants.ResponseKeys.MediumURL] as! String, context: self.sharedContext)
                    photo.pin = self.pin
                }
                
                performUIUpdatesOnMain({ 
//                    self.pin.photos = photos!
                    self.collectionView.reloadData()
                })
            })
        }
    }
    
    // MARK: - Core Data Convenience
    var sharedContext = CoreDataStackManager.sharedInstance().managedObjectContext!
    
    
    //TODO do I need this?
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        // Lay out the collection view so that cells take up 1/3 of the width,
//        // with no space in between.
//        let layout : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
//        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        layout.minimumLineSpacing = 0
//        layout.minimumInteritemSpacing = 0
//        
//        let width = floor(self.collectionView.frame.size.width/3)
//        layout.itemSize = CGSize(width: width, height: width)
//        collectionView.collectionViewLayout = layout
//    }
}

extension PhotoAlbumViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    //MARK - Image Downloading
    
    func downloadImage(imageUrl: String, completionHandler handler: (image: UIImage) -> Void) {
        //Do the downloading on the background thread, then run the completion handler
        // on the main thread
        runInBackgroundQueue { 
            if let url = NSURL(string: imageUrl), imgData = NSData(contentsOfURL: url), image = UIImage(data: imgData) {
                performUIUpdatesOnMain({ 
                    handler(image: image)
                })
            } else {
                print("Error downloading the image")
            }
        }
    }
    
    //MARK - Configure Cell
    
    func configureCell(cell: PhotoAlbumCell, atIndexPath indexPath: NSIndexPath) {
        //Set a placeholder
        cell.imageView.image = UIImage(named: "placeholder")
        //Set the image if it has been downloaded already. If not, grab it on a background thread
        if let image = pin.photos[indexPath.row].image {
            cell.imageView.image = image
        } else {
            downloadImage(pin.photos[indexPath.row].imageUrl, completionHandler: { (image) in
                cell.imageView.image = image
                self.pin.photos[indexPath.row].image = image
            })
        }
    }
    
    //MARK: - UICollectionView
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return 12
        return pin.photos.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoAlbumCell", forIndexPath: indexPath) as! PhotoAlbumCell
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("Selected item at an index path")
    }
}


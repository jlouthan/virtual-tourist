//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Jennifer Louthan on 6/4/16.
//  Copyright © 2016 JennyLouthan. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    var pin: Pin!
    
    // Keep trask of changes. We will track of insertions, deletions, and updates to execute in
    // - controllerDidChangeContent method
    var insertedIndexPaths: [NSIndexPath]!
    var deletedIndexPaths: [NSIndexPath]!
    var updatedIndexPaths: [NSIndexPath]!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Start the fetched results controller
        var error: NSError?
        do {
            try fetchedResultsController.performFetch()
        } catch let error1 as NSError {
            error = error1
        }
        
        if let error = error {
            print("Error performing initial fetch: \(error)")
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //If the pin doesn't have photos yet, fetch from Flickr API
        if pin.photos.isEmpty {
            getPhotos()
        }
    }
    
    //Gets photos for the current pin's location from Flickr,
    // creates Photo managed objects, creates the relationship,
    // and saves the context
    func getPhotos() {
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
                
                //Save the Photos we created and their relationship to the pin
                CoreDataStackManager.sharedInstance().saveContext()
                self.collectionView.reloadData()
            })
        })
    }
    
    
    //MARK: - Refresh photos for pin
    @IBAction func refreshPhotos(sender: UIBarButtonItem) {
        
        //Delete all the photos
        for photo in fetchedResultsController.fetchedObjects as! [Photo] {
            sharedContext.deleteObject(photo)
        }
        
        //Then fetch all new ones
        getPhotos()
    }
    
    // MARK: - Core Data Convenience
    var sharedContext = CoreDataStackManager.sharedInstance().managedObjectContext!
    
    //MARK: - NSFetchedResultsController
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        fetchRequest.sortDescriptors = []
        fetchRequest.predicate = NSPredicate(format: "pin == %@", self.pin)
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
        
    }()
    
    //MARK: - Fetched Results Controller Delegate
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        
        //About to handle new changes
        insertedIndexPaths = [NSIndexPath]()
        deletedIndexPaths = [NSIndexPath]()
        updatedIndexPaths = [NSIndexPath]()
        
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
        
        case .Insert:
            // A new photo has been added to Core Data, track its index to
            // add a cell in -controllerDidChangeContent
            insertedIndexPaths.append(newIndexPath!)
            break
        case .Delete:
            //A photo has been deleted from Core Data, track its old index to
            // remove the cell in - controllerDidChangeContent
            deletedIndexPaths.append(indexPath!)
            break
        case .Update:
            // A Photo instance has changed. Track its index to update
            // the cell in -controllerDidChangeContent
            updatedIndexPaths.append(indexPath!)
            break
        case .Move:
            // We don't expect to be moving Photos
            break
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
        collectionView.performBatchUpdates({() -> Void in
        
            for indexPath in self.insertedIndexPaths {
                self.collectionView.insertItemsAtIndexPaths([indexPath])
            }
            
            for indexPath in self.deletedIndexPaths {
                self.collectionView.deleteItemsAtIndexPaths([indexPath])
            }
            
            for indexPath in self.updatedIndexPaths {
                self.collectionView.reloadItemsAtIndexPaths([indexPath])
            }
            
            }, completion: nil)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Lay out the collection view so that cells take up 1/3 of the width,
        // with no space in between.
        let layout : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let width = floor(self.collectionView.frame.size.width/3)
        layout.itemSize = CGSize(width: width, height: width)
        collectionView.collectionViewLayout = layout
    }
    
}

extension PhotoAlbumViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    //MARK - Image Downloading
    
    func downloadImage(imageUrl: String, completionHandler handler: (imgData: NSData) -> Void) {
        //Do the downloading on the background thread, then run the completion handler
        // on the main thread
        runInBackgroundQueue { 
            if let url = NSURL(string: imageUrl), imgData = NSData(contentsOfURL: url) {
                performUIUpdatesOnMain({ 
                    handler(imgData: imgData)
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
        
        let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        
        //Set the image if it has been downloaded already. If not, grab it on a background thread
        if let imageData = photo.imageData {
            cell.imageView.image = UIImage(data: imageData)
        } else {
            downloadImage(photo.imageUrl, completionHandler: { (imgData) in
                photo.imageData = imgData
                CoreDataStackManager.sharedInstance().saveContext()
            })
        }
    }
    
    //MARK: - UICollectionView
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoAlbumCell", forIndexPath: indexPath) as! PhotoAlbumCell
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        //Remove the photo from core data and update the collection view
        let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        sharedContext.deleteObject(photo)
        CoreDataStackManager.sharedInstance().saveContext()
    }
}


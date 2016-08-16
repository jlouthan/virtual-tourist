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
    
    // The selected indexes array keeps all of the indexPaths for cells that are "selected". The array is
    // used inside cellForItemAtIndexPath to lower the alpha of selected cells.  You can see how the array
    // works by searchign through the code for 'selectedIndexes'
    var selectedIndexes = [NSIndexPath]()
    
    // Keep the changes. We will keep track of insertions, deletions, and updates.
    var insertedIndexPaths: [NSIndexPath]!
    var deletedIndexPaths: [NSIndexPath]!
    var updatedIndexPaths: [NSIndexPath]!
    
    override func viewDidLoad() {
        print("my pin is")
        print(pin.latitude)
        print(pin.longitude)
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
                
                //Save the Photos we created and their relationship to the pin
                CoreDataStackManager.sharedInstance().saveContext()
                
                performUIUpdatesOnMain({ 
                    self.collectionView.reloadData()
                })
            })
        }
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
        
        print("in controllerWillChangeContent")
    }
    
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
            print("image already exists")
            cell.imageView.image = UIImage(data: imageData)
        } else {
            downloadImage(photo.imageUrl, completionHandler: { (imgData) in
                //TODO remove this when pulling photos from fetchedresultscontroller
                cell.imageView.image = UIImage(data: imgData)
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
        print("Selected item at an index path")
    }
}


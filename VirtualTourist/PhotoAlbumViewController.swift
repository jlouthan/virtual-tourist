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
            
            FlickrClient.sharedInstance().getPhotosForLatLong(pin.latitude, longitude: pin.longitude, completionHandlerForGetPhotosForLatLong: { (success, photos) in
                
                guard success == true else {
                    print("Error getting photos")
                    return
                }
                
                self.pin.photos = photos!
                
            })
        }
    }
    
    //TODO do I need this?
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
    
    //MARK - Configure Cell
    
    func configureCell(cell: PhotoAlbumCell, atIndexPath indexPath: NSIndexPath) {
        //Set a placeholder for now
        cell.imageView!.image = UIImage(named: "placeholder")
    }
    
    //MARK: - UICollectionView
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        //TODO return proper number
        return 1;
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //TODO return proper number
        return 12;
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


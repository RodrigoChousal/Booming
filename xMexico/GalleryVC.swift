//
//  GalleryVC.swift
//  xMexico
//
//  Created by Development on 2/17/17.
//  Copyright © 2017 Rodrigo Chousal. All rights reserved.
//

import UIKit

class GalleryVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    private let reuseIdentifier = "GalleryCell"

    @IBOutlet weak var galleryCollectionView: UICollectionView!
    
    var photoGallery = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        galleryCollectionView.delegate = self
        galleryCollectionView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if photoGallery.count == 0 {
			return 3
		} else {
			return photoGallery.count
		}
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! GalleryCell
        
		if photoGallery.count > 0 {
			// Configure the cell
			cell.imageView.image = photoGallery[indexPath.row]
		}
		
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    /*
     // Uncomment this method to specify if the specified item should be highlighted during tracking
     override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment this method to specify if the specified item should be selected
     override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
     override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
     
     }
     */

}

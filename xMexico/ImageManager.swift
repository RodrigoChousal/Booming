//
//  ImageManager.swift
//  xMexico
//
//  Created by Development on 3/13/17.
//  Copyright © 2018 Rodrigo Chousal. All rights reserved.
//

import Foundation
import Firebase

class ImageManager {
    
    static func postImageToFirebase(forUser fireUser: User, image: UIImage) {
        
        let imageData = UIImagePNGRepresentation(image)
        let imagePath = "userPictures/" + fireUser.uid + "/" + "userProfile.png"
        let metadata = StorageMetadata()
        metadata.contentType = "image/png"
        Global.storageRef.child(imagePath)
            .putData(imageData!, metadata: metadata) { (metadata, error) in
                if let error = error {
                    print("Error uploading: \(error)")
                    return
                }
        }
        
    }
    
    static func fetchImageFromFirebase(forUser fireUser: User) -> UIImage {
        let profileImgRef = Global.storageRef.child("userPictures/" + fireUser.uid + "/" + "userProfile.png")
        let imageView: UIImageView = UIImageView()
        imageView.sd_setImage(with: profileImgRef)
        return imageView.image!
    }
}

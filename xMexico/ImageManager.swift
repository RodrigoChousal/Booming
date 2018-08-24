//
//  ImageManager.swift
//  xMexico
//
//  Created by Development on 3/13/17.
//  Copyright © 2018 Rodrigo Chousal. All rights reserved.
//

import Foundation
import Firebase
import FirebaseUI

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
    
    static func postBackgroundImageToFirebase(forUser fireUser: User, image: UIImage) {
        let imageData = UIImagePNGRepresentation(image)
        let imagePath = "userBackgrounds/" + fireUser.uid + "/" + "userBackground.png"
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
    
    static func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
    
    static func fetchImageFromFirebase(forUser fireUser: User, profilePicture: Bool) {
        // Check if profile picture or not, and make reference appropriately
        var imgRef = StorageReference()
        if profilePicture {
            imgRef = Global.storageRef.child("userPictures/" + fireUser.uid + "/" + "userProfile.png")
        } else {
            imgRef = Global.storageRef.child("userPictures/" + fireUser.uid + "/" + "userBackground.png")
        }
        
        var image = UIImage()
        // Fetch the download URL
        imgRef.downloadURL { url, error in
            if let error = error {
                // Handle any errors
                print("Error getting URL: " + error.localizedDescription)
            } else {
                // Get image from Firebase
                if let imageUrl = url {
                    print("Download Started")
                    getDataFromUrl(url: imageUrl) { data, response, error in
                        guard let data = data, error == nil else { return }
                        print(response?.suggestedFilename ?? imageUrl.lastPathComponent)
                        print("Download Finished")
                        DispatchQueue.main.async() {
                            image = UIImage(data: data)!
                            if let user = Global.localUser {
                                if profilePicture {
                                    user.profilePicture = image
                                } else {
                                    user.backgroundPicture = image
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

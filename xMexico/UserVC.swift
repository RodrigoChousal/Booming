//
//  UserVC.swift
//  xMexico
//
//  Created by Development on 2/18/17.
//  Copyright © 2017 Rodrigo Chousal. All rights reserved.
//

import UIKit
import SimpleKeychain

private let reuseIdentifier = "AchievementCell"

class UserVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    @IBOutlet weak var userBgImageView: UIImageView!
    @IBOutlet weak var userPortraitView: UIImageView!
    
    @IBOutlet weak var userDetailsView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var antiquityLabel: UILabel!
    @IBOutlet weak var amountOfDonationsLabel: UILabel!
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var achievementTitleLabel: UILabel!
    
    @IBOutlet weak var achievementCollectionHeaderView: UIView!
    @IBOutlet weak var achievementCollectionView: UICollectionView!
    
    let imagePicker = UIImagePickerController()
    var pickingProfile = false
    var pickingBackground = false
    
    var collectionViewOffset = CGFloat(0)
    var userBgHeight = CGFloat(0)
    var noAchievementsLabel = UILabel()
    var userImage = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        scrollView.delegate = self
        achievementCollectionView.delegate = self
        achievementCollectionView.dataSource = self
        
        navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedStringKey.foregroundColor: UIColor.black,
             NSAttributedStringKey.font: UIFont(name: "Avenir-Medium", size: 17)!]
        
        userBgHeight = userBgImageView.frame.height
        
        setupMenu()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupView()
    }
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let achievements = Global.localUser?.achievements {
            
            if achievements.count == 0 {
                let visibleHeight = (scrollView.frame.height - achievementCollectionHeaderView.frame.origin.y - achievementCollectionHeaderView.frame.height)
                let labelHeight = CGFloat(50)
                let labelInset = CGFloat(10)
                noAchievementsLabel = UILabel(frame: CGRect(x: labelInset, y: 0, width: UIScreen.main.bounds.width - labelInset*2, height: labelHeight))
                noAchievementsLabel.frame.origin.y = visibleHeight/2 - labelHeight
                noAchievementsLabel.textAlignment = .center
                noAchievementsLabel.numberOfLines = 0
                noAchievementsLabel.text = "Apoya una campaña para obtener tu primer reconocimiento!"
                noAchievementsLabel.font = UIFont(name: "Avenir-Medium", size: 14)
                noAchievementsLabel.textColor = .white
                collectionView.addSubview(noAchievementsLabel)
                return 0
            } else {
                noAchievementsLabel.removeFromSuperview()
                return achievements.count
            }
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        
        // Configure the cell
//        let imageView = UIImageView(frame: cell.frame)
//        imageView.image = user.achievements[indexPath.row].icon
//        
//        cell.addSubview(imageView)
        
        if indexPath.row == 9 { // change to number of user achievements
            collectionViewOffset = CGFloat(cell.frame.origin.y)
            scrollView.contentSize = CGSize(width: scrollView.frame.width, height: scrollView.frame.height + collectionViewOffset)
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // TODO: Animated blur effect
        
        let stretchFactor = 1 + abs(scrollView.contentOffset.y / scrollView.frame.height)
        
        if scrollView.contentOffset.y < 0 {
            
            userBgImageView.transform = CGAffineTransform(scaleX: stretchFactor, y: stretchFactor)
            userBgImageView.frame = CGRect(x: userBgImageView.frame.origin.x, y: scrollView.contentOffset.y, width: userBgImageView.frame.width, height: self.userBgHeight - scrollView.contentOffset.y)
        }
    }
    
    // MARK: - Action Methods
    
    @IBAction func openSettings(_ sender: Any) {
        
    }
    
    @IBAction func unwindToUserVC(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func changeProfilePicture(_ sender: Any) {
        // Two buttons below: change or delete?
        animatePressedView(view: userPortraitView)
        showImagePicker(profile: true, background: false)
    }
    
    @IBAction func changeBackgroundPicture(_ sender: Any) {
        // Two buttons below: change or delete?
        animatePressedView(view: userBgImageView)
        showImagePicker(profile: false, background: true)
    }
    
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            
            if pickingProfile {
                
                // FIXME: Still need to upload and update meta
                DispatchQueue.main.async {
                    self.userPortraitView.image = image.circleMasked
                }
                
//                uploadToImgur(image: image, key: "profile")
                pickingProfile = false
                
            } else if pickingBackground {
                
                DispatchQueue.main.async {
                    self.userBgImageView.image = image
                }
                
//                uploadToImgur(image: image, key: "background")
                pickingBackground = false
            }
            
        } else {
            print("Something went wrong")
        }
        
        picker.dismiss(animated: true, completion: { () -> Void in })
    }
    
    // MARK: - Helper Methods
    
    func setupMenu() {
        if revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector((SWRevealViewController.revealToggleMenu) as (SWRevealViewController) -> (Any?) -> Void) as Selector
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        }
    }
    
    func setupView() {
        
        if let user = Global.localUser {
            userPortraitView.image = userImage.circleMasked
            
            userBgImageView.image = user.backgroundPicture
            userBgImageView.contentMode = .scaleAspectFill
            userBgImageView.clipsToBounds = true
            
            nameLabel.text = user.fullName
            bioTextView.text = user.bio
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM yyyy"
            dateFormatter.locale = Locale.init(identifier: "es_ES")
            antiquityLabel.text = "Miembro desde " + dateFormatter.string(from: user.memberSince)
            
            if let city = user.city, let state = user.state {
                cityLabel.text = city + ", " + state
            } else {
                cityLabel.text = "Ubicación desconocida"
            }
            
            if let numberOfCampaigns = user.numberOfCampaigns { amountOfDonationsLabel.text = numberOfCampaigns.description + " campañas apoyadas" }
            if let achievements = user.achievements { achievementTitleLabel.text = "Reconocimientos (\(achievements.count))" }
        }
    }
    
    func updateUserMeta(imageURL: String, deleteHash: String, key: String) {
        
//        let keychain = A0SimpleKeychain(service: "Auth0")
//        if let idToken = keychain.string(forKey: "id_token") {
//            
//            let metaKey = key + "_url"
//            
//            Auth0
//                .users(token: idToken)
//                .patch(userProfile.id, userMetadata: [metaKey: imageURL,
//                                                      metaKey + "_deleteHash": deleteHash])
//                .start { result in
//                    switch result {
//                    case .success( _):
//                        print("Successfully updated user meta.")
//                        
//                    case .failure(let error):
//                        print("Failed to update user meta: \(error)")
//                        SCLAlertView().showError("Lo sentimos", subTitle: "No podemos guardar tu imagen en este momento")
//                    }
//            }
//        }
    }
    
    func animatePressedView(view: UIView) {
        UIView.animate(withDuration: 0.2, animations: { 
            view.alpha = 0.5
        }) { (true) in
            UIView.animate(withDuration: 0.2, animations: { 
                view.alpha = 1.0
            })
        }
    }
    
    func showImagePicker(profile: Bool, background: Bool) {
        
        let picker = self.imagePicker
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.savedPhotosAlbum){
            
            picker.delegate = self
            picker.sourceType = .savedPhotosAlbum
            picker.allowsEditing = true
            
            if profile {
                pickingProfile = true
            } else {
                pickingBackground = true
            }
            
            self.present(picker, animated: true, completion: nil)
        }
    }
}

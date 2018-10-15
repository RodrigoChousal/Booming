//
//  UserVC.swift
//  xMexico
//
//  Created by Development on 2/18/17.
//  Copyright © 2017 Rodrigo Chousal. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

private let reuseIdentifier = "AchievementCell"

class UserVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
	
	@IBOutlet weak var backgroundPictureContainerView: UIView!
	@IBOutlet weak var profilePictureContainerView: UIView!
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
	
	let profilePicturePlaceholderView = LoadingPlaceholderView()
	let backgroundPicturePlaceholderView = LoadingPlaceholderView()
    let imagePicker = UIImagePickerController()
    var pickingProfile = false
    var pickingBackground = false
	var bgImageStandardHeight = CGFloat()
    
    var collectionViewOffset = CGFloat(0)
    var noAchievementsLabel = UILabel()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		NotificationCenter.default.addObserver(self, selector: #selector(setupView), name: .userSettingsDidChange, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(uncoverProfilePicture), name: .profileImageFinished, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(uncoverBackgroundPicture), name: .backgroundImageFinished, object: nil)
        
        imagePicker.delegate = self
        scrollView.delegate = self
        achievementCollectionView.delegate = self
        achievementCollectionView.dataSource = self
        
        navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedStringKey.foregroundColor: UIColor.black,
             NSAttributedStringKey.font: UIFont(name: "Avenir-Medium", size: 17)!]
		
		// TEST ONLY
		if let localUser = Global.localUser {
			localUser.achievements = [Achievement(), Achievement()]
		}
		
        setupMenu()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupView()
    }
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		
		if let achievements = Global.localUser?.achievements {
			
			if achievements.count == 0 {
				return 0
			} else {
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
		
		print(self.scrollView.contentOffset)
		
		
        // TODO: Animated blur effect
        let stretchFactor = 1 + abs(scrollView.contentOffset.y / scrollView.frame.height)
		
        if scrollView.contentOffset.y < 0 {
            userBgImageView.transform = CGAffineTransform(scaleX: stretchFactor, y: stretchFactor)
            userBgImageView.frame = CGRect(x: userBgImageView.frame.origin.x, y: scrollView.contentOffset.y, width: userBgImageView.frame.width, height: self.bgImageStandardHeight - scrollView.contentOffset.y)
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
		
		DispatchQueue.main.async {
			self.view.showLoadingIndicator(withMessage: "Actualizando su foto...")
		}
		
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage, let user = Auth.auth().currentUser, let localUser = Global.localUser {
			if pickingProfile {
				// Upload and update meta
				ImageManager.postImageToFirebase(forFireUser: user, image: image, completion: { error in
					self.view.stopLoadingIndicator()
					if let err = error {
						SCLAlertView().showWarning("Ups!", subTitle: err.localizedDescription)
					} else {
						// Update local user object
						localUser.profilePicture = image
						
						// Update view
						DispatchQueue.main.async {
							self.userPortraitView.image = image.circleMasked
						}
					}
					return
				})
				
				pickingProfile = false
				
			} else if pickingBackground {
				// Upload and update meta
				ImageManager.postBackgroundImageToFirebase(forFireUser: user, image: image, completion: { error in
					self.view.stopLoadingIndicator()
					if let err = error {
						SCLAlertView().showWarning("Ups!", subTitle: err.localizedDescription)
					} else {
						// Update local user object
						localUser.backgroundPicture = image
						
						// Update view
						DispatchQueue.main.async {
							self.userBgImageView.image = image
						}
					}
				})
				
				pickingBackground = false
			}
            print("Finished picking new profile picture...")
            
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
	    
	@objc func setupView() {
		
		self.extendedLayoutIncludesOpaqueBars = true
		profilePictureContainerView.layer.cornerRadius = profilePictureContainerView.frame.width/2
		profilePictureContainerView.clipsToBounds = true
		userPortraitView.layer.cornerRadius = userPortraitView.frame.width/2
		userPortraitView.clipsToBounds = true
		
        if let localUser = Global.localUser {
			
			if let profilePicture = localUser.profilePicture {
				userPortraitView.image = profilePicture.circleMasked
			} else {
				profilePicturePlaceholderView.cover(profilePictureContainerView)
			}
			
			if let backgroundPicture = localUser.backgroundPicture {
				userBgImageView.image = backgroundPicture
			} else {
				backgroundPicturePlaceholderView.cover(backgroundPictureContainerView)
			}
            
            userBgImageView.image = localUser.backgroundPicture
            userBgImageView.contentMode = .scaleAspectFill
            userBgImageView.clipsToBounds = true
			bgImageStandardHeight = userBgImageView.frame.height
            
			nameLabel.text = localUser.fullName
			bioTextView.text = localUser.bio
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM yyyy"
            dateFormatter.locale = Locale.init(identifier: "es_ES")
            antiquityLabel.text = "Miembro desde " + dateFormatter.string(from: localUser.dateCreated)
            
            if let city = localUser.city, let state = localUser.state {
                cityLabel.text = city + ", " + state
            } else {
                cityLabel.text = "Ubicación desconocida"
            }
            
			amountOfDonationsLabel.text = localUser.backedCampaigns.count.description + " campañas apoyadas"
			
            if let achievements = localUser.achievements {
				achievementTitleLabel.text = "Reconocimientos (\(achievements.count))"
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
					achievementCollectionView.addSubview(noAchievementsLabel)
				} else {
					noAchievementsLabel.removeFromSuperview()
				}
			}
        }
    }
	
	@objc func uncoverProfilePicture() {
		profilePicturePlaceholderView.uncover()
		if let localUser = Global.localUser {
			if let profilePicture = localUser.profilePicture {
				userPortraitView.image = profilePicture.circleMasked
			} else {
				print("FALSE POSITIVE: Profile picture finished downloading but local storage is nil.")
			}
		}
	}
	
	@objc func uncoverBackgroundPicture() {
		backgroundPicturePlaceholderView.uncover()
		if let localUser = Global.localUser {
			if let backgroundPicture = localUser.backgroundPicture {
				userBgImageView.image = backgroundPicture
			} else {
				print("FALSE POSITIVE: Background finished downloading but local storage is nil.")
			}
		}
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

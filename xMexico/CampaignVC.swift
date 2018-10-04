//
//  CampaignVC.swift
//  xMexico
//
//  Created by Development on 2/16/17.
//  Copyright © 2017 Rodrigo Chousal. All rights reserved.
//

import UIKit
import FirebaseAuth

class CampaignVC: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
	@IBOutlet weak var missionContainerView: UIView!
	@IBOutlet weak var missionTextView: UITextView!
	@IBOutlet weak var iconContainerView: UIView!
	@IBOutlet weak var headerContainerView: UIView!
	@IBOutlet weak var shareButton: UIButton!
	@IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var descTextView: UITextView!
	@IBOutlet weak var fundsAcquiredLabel: UILabel!
	@IBOutlet weak var addToPortfolioButton: UIButton!
	@IBOutlet weak var questionsButton: UIButton!
	
	var campaign: Campaign!
    var photoGallery = [UIImage]()
    var galleryController = GalleryVC()
	
	var inPortfolio = false
    
    var darkView = UIView()
    var keyboardVisible = false

    override func viewDidLoad() {
        super.viewDidLoad()
				
		scrollView.delegate = self
				
		populateAllFields()
		setupViews()
		setupCampaignImages()
    }
    
    override func viewDidLayoutSubviews() {
        let contentSize = descTextView.sizeThatFits(descTextView.bounds.size)
        var frame = descTextView.frame
        frame.size.height = contentSize.height
        descTextView.frame = frame
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resourc es that can be recreated.
    }
    

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DisplayGallery" {
            galleryController = segue.destination as! GalleryVC
            galleryController.photoGallery = self.photoGallery
        }
    }
	
	// MARK: - Scroll View Delegate
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		if scrollView.contentOffset.y < 0 {
			let newHeight = headerContainerView.frame.origin.y + scrollView.contentOffset.y*(-1)
			let newY = scrollView.contentOffset.y
			resizeMission(newHeight: newHeight, newY: newY)
			
		} else {
			let newHeight = headerContainerView.frame.origin.y
			resizeMission(newHeight: newHeight, newY: CGFloat(0))
		}
	}
	
	// MARK: - Action Methods

    @IBAction func sharePressed(_ sender: Any) {
		let copyAlert = AtomicAlertView(title: "Facebook", linkForCopy: "http://www.apple.com")
		copyAlert.show(animated: true)
    }
    
	@IBAction func questionPressed(_ sender: Any) {
		let copyAlert = AtomicAlertView(title: "Contestamos tus preguntas!", linkForCopy: "http://www.apple.com")
		copyAlert.show(animated: true)
	}
	
	@IBAction func addToPortfolioPressed(_ sender: Any) {
		if inPortfolio {
			let acceptButton = UIButton(type: .system)
			acceptButton.setTitle("SI", for: .normal)
			acceptButton.addTarget(self, action: #selector(removeFromPortfolioPressed), for: .touchUpInside)
			let rejectButton = UIButton(type: .system)
			rejectButton.setTitle("NO", for: .normal)
			let alertView = AtomicAlertView(title: campaign.name, message: "Deseas retirar tu apoyo?", actionButtons: [acceptButton, rejectButton])
			alertView.show(animated: true)
		} else {
			if let localUser = Global.localUser, let fireUser = Auth.auth().currentUser {
				self.addToPortfolioButton.setImage(UIImage(named: "in_portfolio_button"), for: .normal)
				self.addToUserPortfolio(localUser: localUser, fireUser: fireUser)
				self.inPortfolio = true
				self.campaign.numberOfBackers += 1
				self.fundsAcquiredLabel.text = self.campaign.numberOfBackers.description
				let alertView = AtomicAlertView(title: campaign.name, message: "Gracias por agregarnos a tu portafolio")
				alertView.show(animated: true)
			} else {
				// TODO: Presentar Lo sentimos, hubo un problema agregando a tu lista
			}
			
		}
		DispatchQueue.global(qos: .background).async {
			DatabaseManager.updateCampaignBackers(campaign: self.campaign)
		}
	}
	
	// MARK: - Atomic Alert Helper Methods
	
	@objc func removeFromPortfolioPressed() {
		if let localUser = Global.localUser, let fireUser = Auth.auth().currentUser {
			self.addToPortfolioButton.setImage(UIImage(named: "add_campaign_button"), for: .normal)
			self.removeFromUserPortfolio(localUser: localUser, fireUser: fireUser)
			self.inPortfolio = false
			self.campaign.numberOfBackers -= 1
			self.fundsAcquiredLabel.text = self.campaign.numberOfBackers.description
		} else {
			// TODO: Presentar Lo sentimos, hubo un problema quitando de tu lista
		}
	}
	
    // MARK: - Helper Methods
	
	func addToUserPortfolio(localUser: LocalUser, fireUser: User) {
		let backedCampaign = BackedCampaign(amountContributed: 0, dateContributed: Date(), parentID: self.campaign.uniqueID)
		localUser.backedCampaigns.append(backedCampaign)
		SessionManager.updateFireUser(fireUser: fireUser, withLocalUser: localUser)
		NotificationCenter.default.post(name: .portfolioDidChange, object: nil)
	}
	
	func removeFromUserPortfolio(localUser: LocalUser, fireUser: User) {
		var count = 0
		var index = 0
		for backedCampaign in localUser.backedCampaigns {
			if backedCampaign.parentID == self.campaign.uniqueID {
				index = count
			}
			count += 1
		}
		localUser.backedCampaigns.remove(at: index)
		SessionManager.updateFireUser(fireUser: fireUser, withLocalUser: localUser)
		NotificationCenter.default.post(name: .portfolioDidChange, object: nil)
	}
	
	func resizeMission(newHeight: CGFloat, newY: CGFloat) {
		if scrollView.contentOffset.y <= 0 {
			missionContainerView.frame = CGRect(x: 0, y: newY, width: missionContainerView.frame.width, height: newHeight)
			missionTextView.font = UIFont(name: "Avenir-Oblique", size: 14 + scrollView.contentOffset.y*(-0.07))
			missionTextView.frame = CGRect(x: missionTextView.frame.origin.x, y: missionTextView.frame.origin.y, width: missionTextView.frame.width, height: newHeight - missionTextView.frame.origin.y * 2)
		}
	}
	
	func populateAllFields() {
		navigationItem.title = campaign.name
		navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
		
		descTextView.text = campaign.description
		fundsAcquiredLabel.text = campaign.numberOfBackers.description + " personas apoyan esta campaña"
	}
	
	func setupViews() {
		descTextView.isScrollEnabled = false
		descTextView.sizeToFit()
		
		questionsButton.layer.cornerRadius = 8.0
		questionsButton.clipsToBounds = true
		shareButton.layer.cornerRadius = 8.0
		shareButton.clipsToBounds = true
		
		iconContainerView.layer.cornerRadius = iconContainerView.frame.width/2
		iconContainerView.clipsToBounds = true
		
		darkView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
		darkView.backgroundColor = .black
		darkView.alpha = 0.0
		contentView.addSubview(darkView)
		
		if let localUser = Global.localUser {
			for backedCampaign in localUser.backedCampaigns {
				if backedCampaign.parentID == self.campaign.uniqueID {
					addToPortfolioButton.setImage(UIImage(named: "in_portfolio_button"), for: .normal)
					self.inPortfolio = true
				}
			}
		}
	}
	
	func setupCampaignImages() {
		displayCampaignImages()
		if campaign.gallery.count == 0 {
			DispatchQueue.global(qos: .background).async {
				self.loadCampaignImages()
			}
		}
	}
    
    func loadCampaignImages() { // maybe reload data as images load, instead of waiting for all
		
		ImageManager.fetchCampaignImageFromFirebase(forCampaign: campaign, kind: .MAIN, galleryFileName: nil) { (img) in
			self.campaign.mainImage = img
			self.displayCampaignImages()
		}
		
		ImageManager.fetchCampaignImageFromFirebase(forCampaign: campaign, kind: .THUMB, galleryFileName: nil) { (img) in
			if let maskedImage = img.circleMasked {
				self.campaign.thumbnailImage = maskedImage
				self.displayCampaignImages()
			}
		}
		
		for fileName in campaign.galleryImageFileNames {
			ImageManager.fetchCampaignImageFromFirebase(forCampaign: campaign, kind: .GALLERY, galleryFileName: fileName) { (img) in
				self.campaign.gallery.append(img)
				self.displayCampaignImages()
			}
		}		
    }
    
    func displayCampaignImages() {
        iconView.image = campaign.thumbnailImage
        photoGallery = campaign.gallery
        galleryController.photoGallery = self.photoGallery
        galleryController.galleryCollectionView.reloadData()
    }
}

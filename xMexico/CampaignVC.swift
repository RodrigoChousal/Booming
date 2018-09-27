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
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descTextView: UITextView!
	@IBOutlet weak var fundsAcquiredLabel: UILabel!
	@IBOutlet weak var expensesTextView: UITextView!
	@IBOutlet weak var questionsButton: UIView!
	@IBOutlet weak var contributeBottomView: UIView!
	@IBOutlet weak var addToPortfolioButton: UIButton!
	
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

    @IBAction func shareFacebook(_ sender: Any) {
		let alert = AtomicAlertView(title: "Facebook", link: "http://www.apple.com")
		alert.show(animated: true)
    }
    
    @IBAction func shareTwitter(_ sender: Any) {
		let alert = AtomicAlertView(title: "Twitter", link: "http://www.apple.com")
		alert.show(animated: true)
    }
    
    @IBAction func shareWhatsapp(_ sender: Any) {
		let alert = AtomicAlertView(title: "WhatsApp", link: "http://www.apple.com")
		alert.show(animated: true)
    }
    
    @IBAction func shareMail(_ sender: Any) {
		let alert = AtomicAlertView(title: "Mail", link: "http://www.apple.com")
		alert.show(animated: true)
    }
    
    // MARK: - Action Methods
    
	@IBAction func questionPressed(_ sender: Any) {
		print("Tengo una pregunta!")
	}
	
	@IBAction func addToPortfolioPressed(_ sender: Any) {
		if let localUser = Global.localUser, let fireUser = Auth.auth().currentUser {
			if inPortfolio {
				addToPortfolioButton.setImage(UIImage(named: "add_campaign_button"), for: .normal)
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
				self.inPortfolio = false
			} else {
				addToPortfolioButton.setImage(UIImage(named: "in_portfolio_button"), for: .normal)
				let backedCampaign = BackedCampaign(amountContributed: 0, dateContributed: Date(), parentID: self.campaign.uniqueID)
				localUser.backedCampaigns.append(backedCampaign)
				SessionManager.updateFireUser(fireUser: fireUser, withLocalUser: localUser)
				self.inPortfolio = true
			}
		}
	}
	
    // MARK: - Helper Methods
	
	func populateAllFields() {
		navigationItem.title = campaign.name
		navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
		
		nameLabel.text = campaign.name
		descTextView.text = campaign.description
	}
	
	func setupViews() {
		descTextView.isScrollEnabled = false
		descTextView.sizeToFit()
		
		questionsButton.layer.cornerRadius = 8.0
		questionsButton.clipsToBounds = true
		
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
		if campaign.gallery.count == 0 {
			DispatchQueue.global(qos: .background).async {
				self.loadCampaignImages()
			}
		} else {
			displayCampaignImages()
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

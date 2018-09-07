//
//  CampaignVC.swift
//  xMexico
//
//  Created by Development on 2/16/17.
//  Copyright © 2017 Rodrigo Chousal. All rights reserved.
//

import UIKit

class CampaignVC: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descTextView: UITextView!
    @IBOutlet weak var expensesTextView: UITextView!

	@IBOutlet weak var questionsButton: UIView!
	
	@IBOutlet weak var contributeBottomView: UIView!
    @IBOutlet weak var contributeFullControlView: UIView!
    
	var campaign: Campaign!
    var photoGallery = [UIImage]()
    var galleryController = GalleryVC()
    
    var darkView = UIView()
    var keyboardVisible = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        
        navigationItem.title = campaign.name
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        descTextView.isScrollEnabled = false
        descTextView.sizeToFit()
        
        darkView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        darkView.backgroundColor = .black
        darkView.alpha = 0.0
        contentView.addSubview(darkView)
        
        contributeBottomView.alpha = 1.0
        contributeFullControlView.alpha = 0.0
		
		if campaign.gallery.count == 0 {
			DispatchQueue.global(qos: .background).async {
				self.loadCampaignImages()
			}
		} else {
			displayCampaignImages()
		}
		
        nameLabel.text = campaign.name
        descTextView.text = campaign.description
        
        NotificationCenter.default.addObserver(self, selector: #selector(CampaignVC.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CampaignVC.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(CampaignVC.hideKeyboard)))
        
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
        print("Share Facebook")
    }
    
    @IBAction func shareTwitter(_ sender: Any) {
        print("Share Twitter")
    }
    
    @IBAction func shareWhatsapp(_ sender: Any) {
        print("Share Whatsapp")
    }
    
    @IBAction func shareMail(_ sender: Any) {
        print("Share Mail")
    }
    
    // MARK: - UIScrollView Delegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let isBottom = (contentView.frame.height - scrollView.contentOffset.y) <= (scrollView.frame.height)
                
        if isBottom {
//            contributeBottomView.layer.shadowOpacity = 0.0
        } else {
//            contributeBottomView.layer.shadowOpacity = 1.0
        }
    }
    
    // MARK: - Action Methods
    
	@IBAction func questionPressed(_ sender: Any) {
		print("Tengo una pregunta!")
	}
	
	@IBAction func showContribute(_ sender: Any) {
        
        contributeFullControlView.alpha = 1.0
        contributeBottomView.alpha = 0.0
        
        let displacement = contributeFullControlView.frame.height - contributeBottomView.frame.height
        
        // Animate slide-up
        UIView.animate(withDuration: 0.3, animations: {
            self.contributeFullControlView.center.y -= displacement
        }) { (true) in
            // Make scroll view fit new content view position
            self.scrollView.frame.size.height -= displacement
            print(self.contributeFullControlView.frame.origin.y.description)
        }
    }
    
    func hideContributionVC() {
        
        let displacement = contributeFullControlView.frame.height - contributeBottomView.frame.height
        
        // Make scroll view fit new content view position
        self.scrollView.frame.size.height += displacement
        
        // Animate slide-down
        UIView.animate(withDuration: 0.3, animations: {
            self.contributeFullControlView.center.y += displacement
        }) { (true) in
            self.contributeBottomView.alpha = 1.0
            self.contributeFullControlView.alpha = 0.0
            print(self.contributeFullControlView.frame.origin.y.description)
        }
    }
    
    // MARK: - Helper Methods
    
    func loadCampaignImages() { // maybe reload data as images load, instead of waiting for all
		
		ImageManager.fetchCampaignImageFromFirebase(forCampaign: campaign, kind: .MAIN, galleryFileName: nil) { (img) in
			self.campaign.image = img
			self.displayCampaignImages()
		}
		
		ImageManager.fetchCampaignImageFromFirebase(forCampaign: campaign, kind: .THUMB, galleryFileName: nil) { (img) in
			if let maskedImage = img.circleMasked {
				self.campaign.circularImage = maskedImage
				self.displayCampaignImages()
			}
		}
		
		for fileName in campaign.galleryImageFileNames {
			ImageManager.fetchCampaignImageFromFirebase(forCampaign: campaign, kind: .GALLERY, galleryFileName: fileName) { (img) in
				self.campaign.gallery.append(img)
				self.displayCampaignImages()
			}
		}		
        
//        let data = try? Data(contentsOf: campaign.circularImageURL!)
//
//        if let image = UIImage(data: data!) {
//            campaign.circularImage = image
//
//            DispatchQueue.main.sync {
//                self.displayCampaignImages()
//            }
//        }
//
//        for url in campaign.galleryImageURLs {
//            // FIXME: Use ImageManager and change image URLs in Firebase to Firebase URLs
//
//            let data = try? Data(contentsOf: url)
//
//            if let image = UIImage(data: data!) {
//                campaign.gallery.append(image)
//            }
//
//            DispatchQueue.main.sync {
//                self.displayCampaignImages()
//            }
//        }
    }
    
    func displayCampaignImages() {
        iconView.image = campaign.circularImage
        photoGallery = campaign.gallery
        galleryController.photoGallery = self.photoGallery
        galleryController.galleryCollectionView.reloadData()
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        // Disable scrolling
        self.scrollView.isScrollEnabled = false
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            print(keyboardSize.height.description)
            
            if !keyboardVisible {
                print(keyboardSize.height.description)
                self.contributeFullControlView.frame.origin.y -= keyboardSize.height
                
                // Darken rest of view
                darkView.alpha = 0.6
                
            }
            
            keyboardVisible = true
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        
        // Enable scrolling
        self.scrollView.isScrollEnabled = true
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            if keyboardVisible {
                print(keyboardSize.height.description)
                self.contributeFullControlView.frame.origin.y += keyboardSize.height
            }
            
            // Remove dark view
            darkView.alpha = 0.0
        }
        
        keyboardVisible = false
    }
    
    @objc func hideKeyboard() {
        
        if keyboardVisible {
            self.view.endEditing(true)
            keyboardVisible = false
        }
    }
    
    @objc func showConfirmation() {
        
        view.showLoadingIndicator(withMessage: "Procesando su contribuición...")
        
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { (Timer) in
            self.view.stopLoadingIndicator()
            SCLAlertView().showSuccess("Gracias!", subTitle: "Su pago ha sido procesado exitosamente.")
        }
        
    }
}

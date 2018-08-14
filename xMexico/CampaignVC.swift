//
//  CampaignVC.swift
//  xMexico
//
//  Created by Development on 2/16/17.
//  Copyright © 2017 Rodrigo Chousal. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class CampaignVC: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descTextView: UITextView!
    @IBOutlet weak var expensesTextView: UITextView!
    @IBOutlet weak var contributeBottomView: UIView!
    @IBOutlet weak var contributeButton: UIButton!

    var campaign = Campaign()
    var photoGallery = [UIImage]()
    var galleryController = GalleryVC()
    
    var darkView = UIView()
    var keyboardVisible = false
    
    // Contribution controls
    var cancelButton = UIButton()
    var nextButton = UIButton()
    var contributionLabel = UILabel()
    var contributionField = UITextField()
    var contributionFieldBackground = UIImageView()
    var minimumLabel = UILabel()
    var contributeTranslation = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        
        navigationItem.title = campaign.name
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        descTextView.isScrollEnabled = false
        descTextView.sizeToFit()
        
        contributeBottomView.layer.shadowColor = UIColor.black.cgColor
        contributeBottomView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contributeBottomView.layer.shadowOpacity = 1
        contributeBottomView.layer.shadowRadius = 4
        
        darkView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        darkView.backgroundColor = .black
        darkView.alpha = 0.0
        contentView.addSubview(darkView)
        setupContributionControls()
        
        DispatchQueue.global(qos: .background).async {
            self.loadCampaignImages()
        }
        
        nameLabel.text = campaign.name
        descTextView.text = campaign.desc
        
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
            
            contributeBottomView.layer.shadowOpacity = 0.0
        } else {
            contributeBottomView.layer.shadowOpacity = 1.0
        }
    }
    
    // MARK: - Action Methods
    
    @IBAction func showContribute(_ sender: Any) {
        
        self.contributeTranslation = (214 - Int(self.contributeBottomView.frame.height))
        print("Contribute Translation at show: \(contributeTranslation)")
        
        // Set transform identity
        let moveUp = CGAffineTransform(translationX: 0, y: -(CGFloat)(self.contributeTranslation))
        
        // Make view larger
        contributeBottomView.frame = CGRect(x: contributeBottomView.frame.origin.x, y: contributeBottomView.frame.origin.y, width: contributeBottomView.frame.width, height: 214)
        
        // Make scroll view fit new content view position
        scrollView.frame.size.height += -(CGFloat)(self.contributeTranslation)

        // Animate slide-up
        UIView.animate(withDuration: 0.3) {
            self.contributeBottomView.transform = moveUp
        }
        
        // FIXME: Scroll doesn't get to top of view
        
        // Hide 'contribute' button
        contributeButton.alpha = 0.0
        contributeButton.isEnabled = false
        
        // Show controls
        contributeBottomView.addSubview(cancelButton)
        contributeBottomView.addSubview(nextButton)
        contributeBottomView.addSubview(contributionLabel)
        contributeBottomView.addSubview(contributionFieldBackground)
        contributeBottomView.addSubview(contributionField)
        contributeBottomView.addSubview(minimumLabel)
    }
    
    // MARK: - Helper Methods
    
    func loadCampaignImages() { // maybe reload data as images load, instead of waiting for all
        
        let data = try? Data(contentsOf: campaign.circularImageURL!)
        
        if let image = UIImage(data: data!) {
            campaign.circularImage = image
            
            DispatchQueue.main.sync {
                self.displayCampaignImages()
            }
        }
        
        for url in campaign.galleryImageURLs {
            
            print("unpacking url: \(url)")
            
            let data = try? Data(contentsOf: url)
            
            if let image = UIImage(data: data!) {
                campaign.gallery.append(image)
                print("appended image: \(image) to gallery, count at \(campaign.gallery.count)")
            }
            
            DispatchQueue.main.sync {
                self.displayCampaignImages()
            }
        }
    }
    
    func displayCampaignImages() {
        
        iconView.image = campaign.circularImage
        
        photoGallery = campaign.gallery
        galleryController.photoGallery = self.photoGallery
        
        print("")
        print("reloading data...")
        
        galleryController.galleryCollectionView.reloadData()
    }
    
    func setupContributionControls() {
        
        let buttonWidth = contributeBottomView.frame.width * 0.45
        
        // Set 'Cancelar'
        cancelButton = UIButton(frame: CGRect(x: 12, y: 14, width: buttonWidth, height: 56))
        cancelButton.backgroundColor = UIColor(red: 39/255, green: 39/255, blue: 39/255, alpha: 1.0)
        cancelButton.setTitle("Cancelar", for: .normal)
        cancelButton.setTitleColor(UIColor.white, for: .normal)
        cancelButton.titleLabel?.font = UIFont(name: "Avenir-Heavy", size: 18)
        cancelButton.addTarget(self, action: #selector(self.hideContribute), for: .touchUpInside)
        
        // Set 'Siguiente'
        nextButton = UIButton(frame: CGRect(x: (12 + buttonWidth + 12), y: 14, width: buttonWidth, height: 56))
        nextButton.backgroundColor = UIColor(red: 45/255, green: 98/255, blue: 152/255, alpha: 1.0)
        nextButton.setTitle("Siguiente", for: .normal)
        nextButton.setTitleColor(UIColor.white, for: .normal)
        nextButton.titleLabel?.font = UIFont(name: "Avenir-Heavy", size: 18)
        nextButton.addTarget(self, action: #selector(self.showConfirmation), for: .touchUpInside)
        
        // Set contribution label
        contributionLabel = UILabel(frame: CGRect(x: 31, y: 89, width: contributeBottomView.frame.width * 0.5, height: 27))
        contributionLabel.text = "Tu contribución:"
        contributionLabel.font = UIFont(name: "Avenir-Heavy", size: 20)
        contributionLabel.textColor = UIColor(red: 39/255, green: 39/255, blue: 39/255, alpha: 1.0)
        
        // Set text field for quantity
        contributionField = UITextField(frame: CGRect(x: 55, y: 125, width: contributeBottomView.frame.width * 0.94, height: 56))
        contributionField.font = UIFont(name: "Avenir-Heavy", size: 25)
        contributionField.backgroundColor = .clear
        contributionField.keyboardType = .numberPad
        contributionField.textColor = UIColor(red: 39/255, green: 39/255, blue: 39/255, alpha: 1.0)
        
        // Set fake background for text field
        contributionFieldBackground = UIImageView(frame: CGRect(x: 12, y: 123, width: contributeBottomView.frame.width * 0.94, height: 56))
        contributionFieldBackground.image = #imageLiteral(resourceName: "contribution_field")
        
        // Set minimum label
        minimumLabel = UILabel(frame: CGRect(x: 168, y: 188, width: contributeBottomView.frame.width * 0.2, height: 20))
        minimumLabel.text = "$20 mínimo"
        minimumLabel.font = UIFont(name: "Avenir-Medium", size: 15)
        minimumLabel.textColor = UIColor(red: 39/255, green: 39/255, blue: 39/255, alpha: 1.0)
        minimumLabel.sizeToFit()
        minimumLabel.center.x = contributeBottomView.frame.width * 0.5
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        // Disable scrolling
        self.scrollView.isScrollEnabled = false
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            
            if !keyboardVisible {
                self.contributeBottomView.frame.origin.y -= keyboardSize.height
                
                // Darken rest of view
                darkView.alpha = 0.6
                
            }
            
            keyboardVisible = true
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        
        // Enable scrolling
        self.scrollView.isScrollEnabled = true
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            
            if keyboardVisible {
                self.contributeBottomView.frame.origin.y += keyboardSize.height
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
    
    @objc func hideContribute() {
        
        // Show 'contribute' button
        contributeButton.alpha = 1.0
        contributeButton.isEnabled = true
        
        // Remove other controls
        cancelButton.removeFromSuperview()
        nextButton.removeFromSuperview()
        contributionLabel.removeFromSuperview()
        contributionFieldBackground.removeFromSuperview()
        contributionField.removeFromSuperview()
        minimumLabel.removeFromSuperview()
        
        // Set transform identity
        let moveDown = CGAffineTransform(translationX: 0, y: 0)
        
        // Animate slide-down
        UIView.animate(withDuration: 0.3) {
            self.contributeBottomView.transform = moveDown
            self.contentView.transform = moveDown
            self.contributeBottomView.frame.size.height = 57
        }
        
        // Make view smaller
//        contributeBottomView.frame = CGRect(x: contributeBottomView.frame.origin.x, y: contributeBottomView.frame.origin.y, width: contributeBottomView.frame.width, height: 57)
    }
    
    @objc func showConfirmation() {
        
        view.showLoadingIndicator(withMessage: "Procesando su contribuición...")
        
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { (Timer) in
            self.view.stopLoadingIndicator()
            SCLAlertView().showSuccess("Gracias!", subTitle: "Su pago ha sido procesado exitosamente.")
        }
        
    }
}

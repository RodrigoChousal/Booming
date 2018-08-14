//
//  ProductViewController.swift
//  xMexico
//
//  Created by Development on 6/8/17.
//  Copyright © 2017 Rodrigo Chousal. All rights reserved.
//

import UIKit

class ProductViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var segmentedControl: SegmentedControl!
    @IBOutlet weak var deliveryView: UIView!
    @IBOutlet weak var mapView: UIView!
    @IBOutlet weak var addressFormView: UIView!
    
    var photoGallery = [#imageLiteral(resourceName: "sticker1"), #imageLiteral(resourceName: "sticker2")]
    var galleryController = GalleryVC()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupSegmentedControl()
        setupDeliveryView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "DisplayGallery" {
            galleryController = segue.destination as! GalleryVC
            galleryController.photoGallery = self.photoGallery
        }
    }
    
    // MARK: - Helper Methods
    
    func setupSegmentedControl() {
        segmentedControl.items = ["No", "Sí"]
        segmentedControl.selectedLabelColor = .white
        segmentedControl.unselectedLabelColor = UIColor(red: 39/255, green: 39/255, blue: 39/255, alpha: 1.0)
        segmentedControl.borderColor = UIColor(red: 39/255, green: 39/255, blue: 39/255, alpha: 0.5)
        segmentedControl.thumbColor = UIColor(red: 39/255, green: 39/255, blue: 39/255, alpha: 1.0)
        segmentedControl.backgroundColor = .white
        segmentedControl.addTarget(self, action: #selector(self.segmentedControlValueChanged), for: .allEvents)
    }
    
    func setupDeliveryView() {
        
        let screenWidth = UIScreen.main.bounds.width
        
        let horizontalInset = CGFloat(20)
        let verticalInset = CGFloat(12)
        
        // setup mapView
        
        let addressTextView = UITextView(frame: CGRect(x: horizontalInset,
                                                       y: verticalInset,
                                                       width: screenWidth - (horizontalInset * 2),
                                                       height: mapView.frame.height * 0.3))
        addressTextView.text = "Arq Pedro Ramírez Vázquez 200,\nParque Corporativo Ucaly,\n66278,\nSan Pedro Garza García, N.L."
        addressTextView.font = UIFont(name: "Avenir-Light", size: 14)
        
        let mapImageView = UIImageView(frame: CGRect(x: horizontalInset,
                                                     y: (verticalInset * 2 + addressTextView.frame.height),
                                                     width: screenWidth - (horizontalInset * 2),
                                                     height: mapView.frame.height * 0.5))
        mapImageView.image = #imageLiteral(resourceName: "user_bg")
        
        let openExternalBtn = UIButton(frame: CGRect(x: (screenWidth * 0.5 - horizontalInset),
                                                     y: (verticalInset * 3 + addressTextView.frame.height + mapImageView.frame.height),
                                                     width: (screenWidth * 0.5),
                                                     height: mapView.frame.height * 0.1))
        openExternalBtn.setTitle("Abrir en Maps", for: .normal)
        openExternalBtn.backgroundColor = .red
        
        mapView.addSubview(addressTextView)
        mapView.addSubview(mapImageView)
        mapView.addSubview(openExternalBtn)
        
        // setup addressFormView
    }
    
    
    
    @objc func segmentedControlValueChanged() {
        switch segmentedControl.selectedIndex {
        case 0:
            showMapView()
        case 1:
            showAddressFormView()
        default:
            print("def")
        }
    }
    
    func showMapView() {
        
    }
    
    func showAddressFormView() {
    
    }

}


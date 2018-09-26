//
//  CampaignsCVC.swift
//  xMexico
//
//  Created by Development on 2/12/17.
//  Copyright © 2017 Rodrigo Chousal. All rights reserved.
//

import UIKit

class CampaignsCVC: UICollectionViewController, UITableViewDelegate, UITableViewDataSource {
        
    @IBOutlet weak var menuButton: UIBarButtonItem!
	
	var fromMenu = false
	var isLoading = false
    var campaignImages = [UIImage]()
    var topFilter = UIButton(type: .system)
    var shadowView = UIView()
    var optionsTableView = UITableView(frame: CGRect(x: 0, y: -200, width: UIScreen.main.bounds.width, height: 200), style: .plain)
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		if !fromMenu {
			self.navigationController?.view.hide(duration: 1.0)
		}

        setupFilterButton()
        view.addSubview(topFilter)
        
        optionsTableView.isScrollEnabled = false
        optionsTableView.delegate = self
        optionsTableView.dataSource = self
        
        if Global.campaignList.count == 0 {
			self.isLoading = true
			SessionManager.downloadCampaignData(toList: Global.campaignList) {
				self.isLoading = false
				self.loadCampaignImages()
				self.collectionView?.reloadData()
			}
        }
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black,
																   NSAttributedStringKey.font: UIFont(name: "Avenir-Medium", size: 17)!]
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil) // Back button w/o title in campaign details
        
        if revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector((SWRevealViewController.revealToggleMenu) as (SWRevealViewController) -> (Any?) -> Void) as Selector
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
	}
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if !isLoading {
			if segue.identifier == "ShowCampaignSegue" {
				let cell = sender as! CampaignCell
				let indexPath = collectionView?.indexPath(for: cell)
				let campaignDetailVC = segue.destination as! CampaignVC
				campaignDetailVC.campaign = Global.campaignList[(indexPath?.row)!]
			} else if segue.identifier == "FindCampaignSegue" {
				let searchVC = segue.destination as! SearchTableViewController
				searchVC.campaignsArray = Global.campaignList
			}
		}
    }

    // MARK: - UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isLoading {
            return 4
        } else {
            return Global.campaignList.count
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CampaignCell", for: indexPath) as! CampaignCell
        
        if isLoading { // Show template cell
            cell.imageView.image = #imageLiteral(resourceName: "placeholder")
            
            cell.nameLabel.backgroundColor = UIColor(red: 143/255, green: 143/255, blue: 143/255, alpha: 0.5)
            cell.nameLabel.frame = CGRect(x: cell.nameLabel.frame.origin.x, y: cell.nameLabel.frame.origin.y, width: cell.nameLabel.frame.width, height: 15)
            
            cell.infoLabel.backgroundColor = UIColor(red: 143/255, green: 143/255, blue: 143/255, alpha: 0.5)
            cell.infoLabel.frame = CGRect(x: cell.infoLabel.frame.origin.x, y: cell.infoLabel.frame.origin.y, width: cell.infoLabel.frame.width, height: 15)
            
        } else { // Load content into cell
            cell.imageView.image = Global.campaignList[indexPath.row].mainImage
            
            cell.nameLabel.text = Global.campaignList[indexPath.row].name
            cell.nameLabel.backgroundColor = .clear
            cell.nameLabel.sizeToFit()
            
            cell.infoLabel.text = "Desde " + Global.campaignList[indexPath.row].dateCreated.description
            cell.infoLabel.backgroundColor = .clear
            cell.infoLabel.sizeToFit()
        }
        
        return cell
    }

    // MARK: - UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    }
        
    // MARK: - UITableView Data Source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let firstCell = UITableViewCell()
            firstCell.textLabel?.text = "Por popularidad"
            firstCell.textLabel?.font = UIFont(name: "Avenir-Medium", size: 14)
            return firstCell
        case 1:
            let secondCell = UITableViewCell()
            secondCell.textLabel?.text = "Por antiguedad"
            secondCell.textLabel?.font = UIFont(name: "Avenir-Medium", size: 14)
            return secondCell
        case 2:
            let thirdCell = UITableViewCell()
            thirdCell.textLabel?.text = "Por orden alfabético"
            thirdCell.textLabel?.font = UIFont(name: "Avenir-Medium", size: 14)
            return thirdCell
        case 3:
            let fourthCell = UITableViewCell()
            fourthCell.textLabel?.text = "Por necesidad"
            fourthCell.textLabel?.font = UIFont(name: "Avenir-Medium", size: 14)
            return fourthCell
        default:
            let defaultCell = UITableViewCell()
            defaultCell.textLabel?.text = "0"
            defaultCell.textLabel?.font = UIFont(name: "Avenir-Medium", size: 14)
            return defaultCell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(50)
    }
    
    // MARK: - UITableView Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.sort(by: indexPath.row)
    }
    
    // MARK: - Helper Methods
    
    func loadCampaignImages() {
        for campaign in Global.campaignList {
			ImageManager.fetchCampaignImageFromFirebase(forCampaign: campaign, kind: .MAIN, galleryFileName: nil) { (img) in
				campaign.mainImage = img
				self.campaignImages.append(img)
				self.collectionView?.reloadData()
			}
        }
    }
    
    func setupFilterButton() {
		
        topFilter.addTarget(self, action: #selector(CampaignsCVC.filterTapped(_:)), for: .touchDown)
		
		// Makes space for filter button
		collectionView?.frame = CGRect(x: collectionView!.frame.origin.x, y: (collectionView?.frame.origin.y)! + 44, width: (collectionView?.frame.width)!, height: (collectionView?.frame.height)! - 44)
        
        topFilter.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 44)
        topFilter.backgroundColor = UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 1.0)
        topFilter.layer.borderColor = UIColor(red: 231/255, green: 231/255, blue: 231/255, alpha: 1.0).cgColor
        topFilter.layer.borderWidth = 1
        topFilter.setTitle("Mostrando: Todo", for: .normal)
        topFilter.setTitleColor(.black, for: .normal)
        topFilter.tintColor = .black
        
        let heavyFontAttribute = [ NSAttributedStringKey.font: UIFont(name: "Avenir-Heavy", size: 16.0)! ]
        let heavyHalf = NSMutableAttributedString(string: "Mostrando: ", attributes: heavyFontAttribute)
        
        let lightFontAttribute = [ NSAttributedStringKey.font: UIFont(name: "Avenir-Light", size: 16.0)! ]
        let lightHalf = NSAttributedString(string: "Todo", attributes: lightFontAttribute)
        
        heavyHalf.append(lightHalf)
        
        topFilter.setAttributedTitle(heavyHalf, for: .normal)
    }
    
    @objc func filterTapped(_ button: UIButton) {
        
        if optionsTableView.frame.origin.y < 0 {
            
            darkenCollectionView()
			
			
            collectionView?.addSubview(optionsTableView)
            optionsTableView.alpha = 1.0
            
            UIView.animate(withDuration: 0.5) {
                self.optionsTableView.frame = CGRect(x: 0, y: (self.collectionView?.contentOffset.y)!, width: button.frame.width, height: self.optionsTableView.frame.height)
            }
            
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CampaignsCVC.hideShadowView))
            shadowView.addGestureRecognizer(gestureRecognizer)
            
        } else {
            hideShadowView()
        }
    }
    
    func darkenCollectionView() {
        if let collectionView = collectionView {
			
			collectionView.isScrollEnabled = false
            
            shadowView = UIView(frame: CGRect(x: 0, y: (self.collectionView?.contentOffset.y)!, width: collectionView.frame.width, height: collectionView.frame.height))
            shadowView.backgroundColor = .black
            shadowView.alpha = 0.5
            
            collectionView.addSubview(shadowView)
        }
    }
    
    @objc func hideShadowView() {
        shadowView.removeFromSuperview()
		self.collectionView?.isScrollEnabled = true
        
        UIView.animate(withDuration: 0.5, animations: { // This should not be here
            self.optionsTableView.frame = CGRect(x: 0, y: -self.optionsTableView.frame.height, width: self.optionsTableView.frame.width, height: self.optionsTableView.frame.height)
        }) { (Bool) in
            self.optionsTableView.alpha = 0.0
        }
    }
    
    func sort(by kind: Int) {
        
        hideShadowView()
        
        switch kind {
        case 0:
            Global.campaignList = Global.campaignList.sorted(by: { $0.name < $1.name })
            collectionView?.reloadData()
            
        case 1:
            Global.campaignList = Global.campaignList.sorted(by: { $0.dateCreated < $1.dateCreated })
            collectionView?.reloadData()
            
        case 2:
            Global.campaignList = Global.campaignList.sorted(by: { $0.name > $1.name })
            collectionView?.reloadData()
            
        case 3:
            Global.campaignList = Global.campaignList.sorted(by: { $0.name > $1.name })
            collectionView?.reloadData()
            
        default:
            Global.campaignList = Global.campaignList.sorted(by: { $0.name > $1.name })
            collectionView?.reloadData()
            
        }
    }
}

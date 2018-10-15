//
//  BackedCampaignsTVC.swift
//  xMexico
//
//  Created by Development on 7/27/17.
//  Copyright © 2017 Rodrigo Chousal. All rights reserved.
//

import UIKit

class BackedCampaignsTVC: UITableViewController {
	
	var backedCampaignsList = [BackedCampaign]()
	var backedCampaignImages = [UIImage]()
	
    @IBOutlet weak var menuButton: UIBarButtonItem!
		
	override func viewDidLoad() {
        super.viewDidLoad()

		NotificationCenter.default.addObserver(self, selector: #selector(portfolioDidChange), name: .portfolioDidChange, object: nil)
		
		setupMenu()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return backedCampaignsList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BackedCampaignCell", for: indexPath) as! BackedCampaignTVCell
		if let parentCampaign = self.backedCampaignsList[indexPath.row].parentCampaign {
			cell.nameLabel.text = parentCampaign.name
			// Cover loading images
			if backedCampaignImages.count - 1 >= indexPath.row {
				cell.campaignImage.image = parentCampaign.thumbnailImage
				cell.imagePlaceholder.uncover()
			} else {
				cell.imagePlaceholder.cover(cell.campaignImageContainerView)
			}
			
		}
        return cell
    }
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
	}

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "ShowBackedCampaignSegue" {
			let cell = sender as! BackedCampaignTVCell
			if let indexPath = tableView?.indexPath(for: cell) {
				if let campaign = backedCampaignsList[indexPath.row].parentCampaign {
					let campaignDetailVC = segue.destination as! CampaignVC
					campaignDetailVC.campaign = campaign
				}
			}
		}
    }
	
	// MARK: - Selectors
	
	@objc func portfolioDidChange() {
		if let localUser = Global.localUser {
			self.backedCampaignsList = localUser.backedCampaigns
			self.tableView.reloadData()
		}
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
	
	func loadBackedCampaigns(forLocalUser localUser: LocalUser) {
		SessionManager.downloadBackedCampaignData(fromLocalUser: localUser, completion: {
			self.backedCampaignsList = localUser.backedCampaigns
			self.loadBackedCampaignImages()
			self.tableView.reloadData()
		})
	}
	
	func loadBackedCampaignImages() {
		for backedCampaign in backedCampaignsList {
			if let parentCampaign = backedCampaign.parentCampaign {
				ImageManager.fetchCampaignImageFromFirebase(forCampaign: parentCampaign, kind: .THUMB, galleryFileName: nil) { (img) in
					parentCampaign.thumbnailImage = img
					self.backedCampaignImages.append(img)
					self.tableView.reloadData()
				}
			} else {
				print("IS AN ORPHAN :(")
			}
		}
		
	}
}

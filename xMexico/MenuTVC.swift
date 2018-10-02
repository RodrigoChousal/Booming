//
//  MenuTVC.swift
//  xMexico
//
//  Created by Development on 2/18/17.
//  Copyright © 2017 Rodrigo Chousal. All rights reserved.
//

import UIKit

class MenuTVC: UITableViewController {
    
    var indicatorView = UIView()

    @IBOutlet weak var userCell: UITableViewCell!
    @IBOutlet weak var accountTitleLabel: UILabel!
    @IBOutlet weak var userPictureView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var campaignsCell: UITableViewCell!
        
    override func viewDidLoad() {
        super.viewDidLoad()
		
		NotificationCenter.default.addObserver(self, selector: #selector(setupView), name: .userSettingsDidChange, object: nil)
        
        self.revealViewController().rearViewRevealWidth = 200
        self.revealViewController().rearViewRevealDisplacement = 0
        self.revealViewController().springDampingRatio = 1.0
        
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let localUser = Global.localUser {
            userPictureView.image = localUser.profilePicture.circleMasked
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "BackedCampaignsSegue" {
			let destination = segue.destination as! UINavigationController
			if let localUser = Global.localUser {
				let backedVC = destination.topViewController as! BackedCampaignsTVC
				backedVC.loadBackedCampaigns(forLocalUser: localUser)
				backedVC.loadBackedCampaignImages()
			}
		} else if segue.identifier == "CampaignsSegue" {
			let destination = segue.destination as! UINavigationController
			let campaignsCVC = destination.topViewController as! CampaignsCVC
			campaignsCVC.fromMenu = true
		}
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 { // User VC
            
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 { // userCell is taller
            if isVisitor {
                return 54
            }
            return 125
        }
		
        return 54 // menu item cells
    }
    
    // MARK: - Helper Methods
    
    @objc func setupView() {
		
        if !isVisitor {
            DispatchQueue.main.async {
                if let user = Global.localUser {
                    self.userNameLabel.text = user.fullName
                    self.userPictureView.image = user.profilePicture.circleMasked
                }
            }
            
        } else {
            userNameLabel.removeFromSuperview()
            userPictureView.removeFromSuperview()
            accountTitleLabel.removeFromSuperview()

            // Use campaignsCell for size because userCell will be resized after viewDidLoad in heightForRow
            let accessLabel = UILabel(frame: userNameLabel.frame)
            accessLabel.center = campaignsCell.contentView.center
            accessLabel.center.x = campaignsCell.contentView.center.x
            accessLabel.center.y = campaignsCell.contentView.center.y
            accessLabel.text = "Crear Cuenta"
            accessLabel.textAlignment = .center
            accessLabel.font = UIFont(name: "Avenir-Heavy", size: 14)
            accessLabel.textColor = .blue

            userCell.contentView.addSubview(accessLabel)
        }
    }
}

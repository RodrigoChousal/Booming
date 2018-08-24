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
    var didLogout = false

    @IBOutlet weak var userCell: UITableViewCell!
    @IBOutlet weak var accountTitleLabel: UILabel!
    @IBOutlet weak var userPictureView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var campaignsCell: UITableViewCell!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.revealViewController().rearViewRevealWidth = 200
        self.revealViewController().rearViewRevealDisplacement = 0
        self.revealViewController().springDampingRatio = 1.0
        
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let locUser = Global.localUser {
            userPictureView.image = locUser.profilePicture.circleMasked
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 0 { // User VC
            
        } else if indexPath.row == 1 { // Campaigns VC
            
            // FIXME: Bad design
            userSignedIn = false
            
        } else if indexPath.row == 2 { // Proposal VC
            
        } else if indexPath.row == 3 { // Mission VC
            
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 { // userCell is usually taller
            
            if isVisitor {
                return 54
            }
            return 125
        }
        return 54 // menu item cells
    }
    
    // MARK: - Helper Methods
    
    func setupView() {
        
        print("Setting up view in menu...")
    
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

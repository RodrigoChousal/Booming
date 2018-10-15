//
//  BackedCampaignTVCell.swift
//  xMexico
//
//  Created by Rodrigo Chousal on 9/4/18.
//  Copyright © 2018 Rodrigo Chousal. All rights reserved.
//

import UIKit

class BackedCampaignTVCell: UITableViewCell {

	let imagePlaceholder = LoadingPlaceholderView()
	@IBOutlet weak var campaignImageContainerView: UIView!
	@IBOutlet weak var campaignImage: UIImageView!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var favoriteButton: UIButton!
	
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
		nameLabel.font = UIFont(name: "Avenir-Heavy", size: CGFloat(20))
		campaignImageContainerView.layer.cornerRadius = campaignImageContainerView.frame.width/2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

	@IBAction func favoritePressed(_ sender: Any) {
		
	}
}

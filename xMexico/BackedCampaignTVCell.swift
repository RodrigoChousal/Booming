//
//  BackedCampaignTVCell.swift
//  xMexico
//
//  Created by Rodrigo Chousal on 9/4/18.
//  Copyright © 2018 Rodrigo Chousal. All rights reserved.
//

import UIKit

class BackedCampaignTVCell: UITableViewCell {

	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var amountLabel: UILabel!
	@IBOutlet weak var statusLabel: UILabel!
	
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

//
//  DatabaseManager.swift
//  xMexico
//
//  Created by Rodrigo Chousal on 9/4/18.
//  Copyright © 2018 Rodrigo Chousal. All rights reserved.
//

import Foundation

class DatabaseManager {
	
	// MARK: - Custom-to-Uploadable Native
	static func uploadableBackedCampaigns(fromArray backedCampaignsArray: [BackedCampaign]) -> NSArray {
		var uploadable = NSArray()
		for backedCampaign in backedCampaignsArray { // FIXME: How do I know uniqueID?
			let uploadableDictionary = ["amount_contributed" : backedCampaign.amountContributed,
										"date_contributed" : backedCampaign.dateContributed,
										"campaign_id" : backedCampaign.parentID] as [String : Any]
			uploadable = uploadable.adding(uploadableDictionary) as NSArray
		}
		return uploadable
	}
	
	// MARK: - String-to-Native Class
	
	static func validDate(fromString dateString: String) -> Date {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
		if let date = dateFormatter.date(from: dateString)  {
			return date
		} else {
			print("ERROR! Date was not valid, returned error value: " + Date().description)
			return Date()
		}
	}
	
	static func validFunds(fromString fundsString: String) -> Int { // TODO: Eventually change from Int to Funds object
		if let funds = Int(fundsString) {
			return funds
		} else {
			return 0
		}
	}
	
	// MARK: - Native-to-Custom Class
	
	static func validBackedCampaign(fromDictionary dictionary: NSDictionary) -> BackedCampaign {
		let amountContributed = validFunds(fromString: dictionary.value(forKey: "contribution_amount") as! String)
		let dateContributed = validDate(fromString: dictionary.value(forKey: "contribution_date") as! String)
		let parentID = dictionary.value(forKey: "campaign_id") as! String
		let backedCampaign = BackedCampaign(amountContributed: amountContributed,
											dateContributed: dateContributed,
											parentID: parentID)
		return backedCampaign
	}
	
	static func validCampaign(withID campaignID: String, fromDictionary dictionary: NSDictionary) -> Campaign {
		print(dictionary)
		let campaign = Campaign(uniqueID: campaignID,
								status: validStatus(fromString: dictionary.value(forKey: "status") as! String),
								name: dictionary.value(forKey: "name") as! String,
								description: dictionary.value(forKey: "description") as! String,
								objective: dictionary.value(forKey: "objective") as! String,
								dateCreated: validDate(fromString: dictionary.value(forKey: "date_created") as! String),
								contact: validContact(fromDictionary: dictionary.value(forKey: "contact") as! NSDictionary),
								fundsNeeded: validFunds(fromString: dictionary.value(forKey: "funds_needed") as! String))
		campaign.image = #imageLiteral(resourceName: "placeholder")
		campaign.imageURL = URL(string: dictionary.value(forKey: "logo_170x224") as! String)
		campaign.circularImageURL = URL(string: dictionary.value(forKey: "logo_142x142") as! String)
		if let imageFileNames = dictionary.value(forKey: "photo_gallery") as? NSArray {
			for fileName in imageFileNames {
				if let str = fileName as? String {
					campaign.galleryImageFileNames.append(str)
				}
			}
		}
		return campaign
	}
	
	static func validStatus(fromString statusString: String) -> Campaign.Status {
		if let status = Campaign.Status.init(rawValue: statusString) {
			return status
		} else {
			return Campaign.Status.UNKNOWN
		}
	}
	
	static func validContact(fromDictionary contactDictionary: NSDictionary) -> Contact {
		let email = contactDictionary.value(forKey: "email") as! String
		let name = contactDictionary.value(forKey: "name") as! String
		let cell = contactDictionary.value(forKey: "cell") as! String
		let contact = Contact(email: email, name: name, cell: cell)
		return contact
	}
}

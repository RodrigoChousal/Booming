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
			let uploadableDictionary = ["amount_contributed" : backedCampaign.amountContributed.description, // FIXME: Consider changing to Int and Date (supported)
										"date_contributed" : backedCampaign.dateContributed.description,
										"campaign_id" : backedCampaign.parentID] as [String : Any]
			uploadable = uploadable.adding(uploadableDictionary) as NSArray
		}
		return uploadable
	}
	
	// MARK: - Other
	
	static func updateCampaignBackers(campaign: Campaign) {
		Global.campaignsCollectionRef.document(campaign.uniqueID)
			.updateData(["number_of_backers" : campaign.numberOfBackers.description ]) { err in
				if let err = err {
					print("Error updating document: \(err)")
				} else {
					print("Document successfully updated")
				}
		}
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
	
	static func validNumberOfBackers(fromString backersString: String) -> Int {
		if let backers = Int(backersString) {
			return backers
		} else {
			return 0
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
		print(dictionary)
		let amountContributed = validFunds(fromString: dictionary.value(forKey: "amount_contributed") as! String)
		let dateContributed = validDate(fromString: dictionary.value(forKey: "date_contributed") as! String)
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
								type: dictionary.value(forKey: "type") as! String,
								description: dictionary.value(forKey: "description") as! String,
								objective: dictionary.value(forKey: "objective") as! String,
								dateCreated: validDate(fromString: dictionary.value(forKey: "date_created") as! String),
								contact: validContact(fromDictionary: dictionary.value(forKey: "contact") as! NSDictionary),
								numberOfBackers: validNumberOfBackers(fromString: dictionary.value(forKey: "number_of_backers") as! String),
								fundsNeeded: validFunds(fromString: dictionary.value(forKey: "funds_needed") as! String))
		campaign.mainImage = #imageLiteral(resourceName: "placeholder")
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

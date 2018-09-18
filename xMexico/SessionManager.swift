//
//  SessionManager.swift
//  xMexico
//
//  Created by Rodrigo Chousal on 9/5/18.
//  Copyright © 2018 Rodrigo Chousal. All rights reserved.
//

import Foundation
import Firebase

class SessionManager {
	
	// MARK: - UP ☁️
	
	static func populateFireUser(fireUser: User, withLocalUser localUser: LocalUser) {
		Global.usersCollectionRef.document(fireUser.uid)
			.setData(["email" : localUser.email,
					  "first_name" : localUser.firstName,
					  "last_name" : localUser.lastName,
					  "date_created" : localUser.dateCreated.description,
					  "bio" : localUser.bio ?? "",
					  "city" : localUser.city ?? "",
					  "state" : localUser.state ?? "",
					  "achievements" : localUser.achievements ?? [Achievement](), // TODO: uploadableAchievements
					  "backed_campaigns" : DatabaseManager.uploadableBackedCampaigns(fromArray: localUser.backedCampaigns)])
		let changeRequest = fireUser.createProfileChangeRequest()
		changeRequest.displayName = localUser.firstName + " " + localUser.lastName
		ImageManager.postImageToFirebase(forFireUser: fireUser, image: localUser.profilePicture, completion: nil)
		ImageManager.postBackgroundImageToFirebase(forFireUser: fireUser, image: localUser.backgroundPicture!, completion: nil)
	}
	
	static func updateFireUser(fireUser: User, withLocalUser localUser: LocalUser) {
				Global.usersCollectionRef.document(fireUser.uid)
					.updateData(["email" : localUser.email,
								 "first_name" : localUser.firstName,
								 "last_name" : localUser.lastName,
								 "date_created" : localUser.dateCreated.description,
								 "bio" : localUser.bio ?? "",
								 "city" : localUser.city ?? "",
								 "state" : localUser.state ?? "",
								 // "achievements" : localUser.achievements ?? [Achievement](), // TODO: uploadableAchievements
								 "backed_campaigns" : DatabaseManager.uploadableBackedCampaigns(fromArray: localUser.backedCampaigns)
				]) { err in
					if let err = err {
						print("Error updating document: \(err)")
					} else {
						print("Document successfully updated")
					}
				}
	}
	
	// MARK: - DOWN ☔️
	
	static func populateLocalUser(withFireUser fireUser: User) {
		Global.usersCollectionRef.document(fireUser.uid).getDocument { (document, error) in
			if let value = document?.data() as NSDictionary? {
				let firstName = value["first_name"] as? String ?? ""
				let lastName = value["last_name"] as? String ?? ""
				let email = value["email"] as? String ?? ""
				let dateCreated = DatabaseManager.validDate(fromString: value["date_created"] as? String ?? "")
				let backedCampaignsDictionaries = value["backed_campaigns"] as? NSArray ?? NSArray()
				var backedCampaigns = [BackedCampaign]()
				for backedCampaignDictionary in backedCampaignsDictionaries {
					backedCampaigns.append(DatabaseManager.validBackedCampaign(fromDictionary: backedCampaignDictionary as! NSDictionary))
				}
				Global.localUser = LocalUser(firstName: firstName,
											 lastName: lastName,
											 email: email,
											 dateCreated: dateCreated,
											 backedCampaigns: backedCampaigns)
				ImageManager.fetchImageFromFirebase(forFireUser: fireUser, profilePicture: true)
				ImageManager.fetchImageFromFirebase(forFireUser: fireUser, profilePicture: false)
			} else if let error = error {
				print("ERROR:" + error.localizedDescription)
			}
		}
	}
	
	static func downloadCampaignData(toList campaignList: [Campaign], completion: @escaping () -> Void) {
		Global.campaignsCollectionRef.getDocuments { (querySnapshot, error) in
			if let error = error {
				print("Error getting documents: \(error)")
			} else {
				for document in querySnapshot!.documents {
					if let campaignDictionary = document.data() as NSDictionary? {
						let campaign = DatabaseManager.validCampaign(withID: document.documentID, fromDictionary: campaignDictionary)
						Global.campaignList.append(campaign)
						print("Appended campaign to global campaign list")
						// Use to update necessary views
						completion()
					}
				}
			}
		}
	}
	
	static func downloadBackedCampaignData(fromLocalUser localUser: LocalUser, completion: @escaping () -> Void) {
		for backedCampaign in localUser.backedCampaigns {
			Global.campaignsCollectionRef.document(backedCampaign.parentID).getDocument { (document, error) in
				if let campaignDictionary = document?.data() as NSDictionary? {
					let campaign = DatabaseManager.validCampaign(withID: backedCampaign.parentID, fromDictionary: campaignDictionary)
					backedCampaign.parentCampaign = campaign
					completion()
				}
			}
		}
	}
}

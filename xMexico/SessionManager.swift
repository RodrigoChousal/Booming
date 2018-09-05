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
	
	static func populate(fireUser: User, withLocalUser localUser: LocalUser) {
		Global.usersCollectionRef.addDocument(data: ["email" : localUser.email,
													 "first_name" : localUser.firstName,
													 "last_name" : localUser.lastName,
													 "date_created" : localUser.dateCreated.description,
													 "bio" : localUser.bio ?? "",
													 "city" : localUser.city ?? "",
													 "state" : localUser.state ?? "",
													 "backed_campaigns" : DatabaseManager.uploadableBackedCampaigns(fromArray: localUser.backedCampaigns)])
		let changeRequest = fireUser.createProfileChangeRequest()
		changeRequest.displayName = localUser.firstName + " " + localUser.lastName
		ImageManager.postImageToFirebase(forFireUser: fireUser, image: localUser.profilePicture)
		ImageManager.postBackgroundImageToFirebase(forFireUser: fireUser, image: localUser.backgroundPicture!)
	}
}

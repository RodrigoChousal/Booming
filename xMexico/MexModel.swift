//
//  MexModel.swift
//  xMexico
//
//  Created by Development on 2/13/17.
//  Copyright © 2017 Rodrigo Chousal. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseFirestore

class Global {
    static var localUser: LocalUser? // Optional because users can enter as visitors
	static var campaignList = [Campaign]()

	// Realtime Database
    static let databaseRef = Database.database().reference()
    static let storageRef = Storage.storage().reference()
	
	// Cloud Firestore
	static let usersCollectionRef = Firestore.firestore().collection("users")
	static let campaignsCollectionRef = Firestore.firestore().collection("campaigns")
}

class Campaign {
	
	var uniqueID: String
	var name: String
    var description: String
	var objective: String
	var dateCreated: Date
	var contact: Contact
	var fundsNeeded: Int //TODO: Make class with currency property
	var numberOfBackers: Int
	var status: Status
	
	var fundsAcquired: Int = 0
	
	var supporters: [User]?
	
	var mainImage: UIImage = UIImage()
    var thumbnailImage: UIImage = UIImage()
    var gallery = [UIImage]()
	var galleryImageFileNames = [String]()
	
	enum Status: String {
		case ONGOING = "EnProgreso"
		case CANCELED = "Cancelada"
		case COMPLETED = "Completada"
		case UNKNOWN = "Unknown"
	}
	
	enum ImageType: String {
		case MAIN = "Main"
		case THUMB = "Thumb"
		case GALLERY = "Gallery"
	}
	
	init(uniqueID: String, status: Status, name: String, description: String, objective: String, dateCreated: Date, contact: Contact, numberOfBackers: Int, fundsNeeded: Int) {
		self.uniqueID = uniqueID
		self.status = status
		self.name = name
		self.description = description
		self.objective = objective
		self.dateCreated = dateCreated
		self.contact = contact
		self.numberOfBackers = numberOfBackers
		self.fundsNeeded = fundsNeeded
	}
}

class BackedCampaign {
	var amountContributed: Int
	var dateContributed: Date
	var parentID: String
	var parentCampaign: Campaign?
	init(amountContributed: Int, dateContributed: Date, parentID: String) {
		self.amountContributed = amountContributed
		self.dateContributed = dateContributed
		self.parentID = parentID
	}
}

class Contact {
	var email: String
	var name: String
	var cell: String
	
	init(email: String, name: String, cell: String) {
		self.email = email
		self.name = name
		self.cell = cell
	}
}

class LocalUser {
    
    // Obligatory data (set during signup)
    var firstName: String
    var lastName: String
    var fullName: String { return firstName + " " + lastName }
    var email: String
    var dateCreated: Date
	var backedCampaigns: [BackedCampaign]
	
	// Obligatory properties with default values
	var profilePicture: UIImage = #imageLiteral(resourceName: "placeholder")
    
    // Optional properties (set later in Settings VC)
    var backgroundPicture: UIImage?
    var city: String?
    var state: String?
    var bio: String?
    var achievements: [Achievement]?
    
    func setNames(from fullName: String) {
        var fullNameArr = fullName.components(separatedBy: " ")
        firstName = fullNameArr.removeFirst()
        lastName = fullNameArr.joined(separator: " ")
    }
    
	init(firstName: String, lastName: String, email: String, dateCreated: Date, backedCampaigns: [BackedCampaign]) {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
		self.dateCreated = dateCreated
		self.backedCampaigns = backedCampaigns
    }
}

struct Credentials {
    var email: String
    var password: String
}

class Achievement {
    var icon: UIImage = UIImage()
    var name: String = ""
    var desc: String = ""
}

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

class Global {
    static var localUser: LocalUser? // Optional because users can enter as visitors
    static let databaseRef = Database.database().reference()
    static let storageRef = Storage.storage().reference()
}

class Campaign {
    
	var name: String = ""
    var desc: String = ""
    var date: String = ""
    var contact: String = ""
	var supporters: [LocalUser] = [LocalUser]()
    
    var image: UIImage = UIImage()
    var imageURL: URL?
    
    var circularImage: UIImage = UIImage()
    var circularImageURL: URL?
    
    var gallery = [UIImage]()
    var galleryImageURLs = [URL]()
    
    convenience init(name: String, desc: String, contact: String) {
        self.init()
        self.name = name
        self.desc = desc
        self.contact = contact
    }
}

class BackedCampaign: Campaign {
	var contributionAmount: Int = 0
	var status: String = "status"
}

class LimitedCampaign: Campaign {
    var goal: Int = 0
    var progress: Int = 0
    var expenseList: String = ""
}

class LocalUser {
    
    // Obligatory data (set during signup)
    var firstName: String
    var lastName: String
    var fullName: String { return firstName + " " + lastName }
    var email: String
    var memberSince: Date = Date()
    var profilePicture: UIImage = #imageLiteral(resourceName: "placeholder")
	var backedCampaigns: [BackedCampaign] = [BackedCampaign]()
    
    // Optional data
    var backgroundPicture: UIImage?
    var numberOfCampaigns: Int?
    var city: String?
    var state: String?
    var bio: String?
    var achievements: [Achievement]?
    
    func setNames(from fullName: String) {
        var fullNameArr = fullName.components(separatedBy: " ")
        firstName = fullNameArr.removeFirst()
        lastName = fullNameArr.joined(separator: " ")
    }
    
    init(firstName: String, lastName: String, email: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
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

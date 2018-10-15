//
//  LostPasswordVC.swift
//  xMexico
//
//  Created by Rodrigo Chousal on 10/15/18.
//  Copyright © 2018 Rodrigo Chousal. All rights reserved.
//

import UIKit
import FirebaseAuth

class LostPasswordVC: UIViewController {
	
	@IBOutlet weak var sendLinkButton: UIButton!
	@IBOutlet weak var emailField: UITextField!
	
    override func viewDidLoad() {
        super.viewDidLoad()

		sendLinkButton.layer.cornerRadius = 16
    }
	
	@IBAction func sendLink(_ sender: Any) {
		if let email = emailField.text, let buttonTitle = sendLinkButton.titleLabel {
			Auth.auth().sendPasswordReset(withEmail: email) { (error) in
				if let err = error {
					print(err.localizedDescription)
					self.sendLinkButton.backgroundColor = .red
					buttonTitle.text = "Intenta de nuevo más tarde"
				} else {
					self.sendLinkButton.backgroundColor = .green
					buttonTitle.text = "Instrucciones enviadas a " + email
				}
			}
		}
	}
	
	@IBAction func cancelReset(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
	}
}

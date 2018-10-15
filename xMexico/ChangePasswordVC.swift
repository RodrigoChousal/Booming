//
//  ChangePasswordVC.swift
//  xMexico
//
//  Created by Rodrigo Chousal on 10/15/18.
//  Copyright © 2018 Rodrigo Chousal. All rights reserved.
//

import UIKit
import FirebaseAuth

class ChangePasswordVC: UIViewController {

	@IBOutlet weak var oldPasswordField: UITextField!
	@IBOutlet weak var newPasswordField: UITextField!
	@IBOutlet weak var newPasswordConfirmField: UITextField!
	
	override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
	
	// MARK: - Helper Methods
	
	// TODO: Probably better to show red label in the view controller that says these alerts instead of popup
	func passesTests() -> Bool {
		if let oldPassword = oldPasswordField.text, let newPassword = newPasswordField.text, let newPasswordConfirm = newPasswordConfirmField.text {
			if oldPassword == newPassword {
				SCLAlertView().showWarning("Ups!", subTitle: "No puedes cambiar a la vieja contraseña")
				return false
			} else if newPassword != newPasswordConfirm {
				SCLAlertView().showWarning("Ups!", subTitle: "Asegura que hayas escrito la nueva contraseña correctamente")
				return false
			}
		} else {
			SCLAlertView().showWarning("Ups!", subTitle: "Asegura que hayas llenado todos los campos")
			return false
		}
		return true
	}
	
	// MARK: - Action Methods
    
	@IBAction func savePressed(_ sender: Any) {
		if let fireUser = Auth.auth().currentUser, passesTests() {
			fireUser.updatePassword(to: "") { (error) in
				if let err = error {
					SCLAlertView().showWarning("Ups!", subTitle: "Hubo un error. Intenta nuevamente en un momento.")
					print(err.localizedDescription)
				}
			}
		}
	}
}

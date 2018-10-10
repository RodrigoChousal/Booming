//
//  SettingsTableViewController.swift
//  xMexico
//
//  Created by Development on 4/11/17.
//  Copyright © 2017 Rodrigo Chousal. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class SettingsTableViewController: UITableViewController, UITextViewDelegate, UITextFieldDelegate {
    
	@IBOutlet weak var saveButton: UIBarButtonItem!

    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var cityField: UITextField!
    @IBOutlet weak var stateField: UITextField!
	
	let endEditingButton = UIButton(type: .system)
    var keyboardVisible = false
    var successfulSave = false
	
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedStringKey.foregroundColor: UIColor.black,
             NSAttributedStringKey.font: UIFont(name: "Avenir-Medium", size: 17)!]
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        saveButton.isEnabled = false
        saveButton.setTitleTextAttributes([NSAttributedStringKey.font : UIFont(name: "Avenir-Medium", size: 15)!], for: .normal)
		
		setupCancelEditingButton()
		setupTextFields()
        fillTextFields()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        fillTextFields()
    }
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .default
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    // MARK: - Action Methods
    
    @IBAction func cancel(_ sender: Any) {
        // Hide keyboard and dismiss changes
        tableView.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: Any) {
        // Hide keyboard and save changes
        tableView.endEditing(true)
		view.showLoadingIndicator(withMessage: "Guardando...")
		let success = saveSettings {
			self.view.stopLoadingIndicator()
		}
		
		if success {
			NotificationCenter.default.post(name: .userSettingsDidChange, object: nil)
			self.dismiss(animated: true, completion: nil)
		} else {
			// TODO: Present an alert view
		}
    }
    
	func saveSettings(completion: @escaping () -> ()) -> Bool {
        
        // Check for empty fields
        for field in [firstNameField, lastNameField, emailField, cityField, stateField] {
            if field?.text == "" {
                SCLAlertView().showWarning("Disculpa la molestia", subTitle: "Favor de no dejar ningun campo en blanco")
				completion()
                return false
            }
        }
        
        // Save any changes:
        if let fireUser = Auth.auth().currentUser, let localUser = Global.localUser {
            
            // Locally
            localUser.firstName = firstNameField.text!
            localUser.lastName = lastNameField.text!
            localUser.bio = bioTextView.text!
            localUser.city = cityField.text!
            localUser.state = stateField.text!
            
            // In d cloud
			SessionManager.updateFireUser(fireUser: fireUser, withLocalUser: localUser)
			
			completion()
        }
		return true
    }
    
    // MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		print(indexPath.row)
		
        tableView.deselectRow(at: indexPath, animated: true)
		
        if indexPath.row == 10 { // logout cell index path
			self.logOut()
        }
    }
    
    // MARK: - Text View Delegate
		
	func textViewDidBeginEditing(_ textView: UITextView) {
		let currentTextColor = textView.textColor
		if currentTextColor != .black {
			textView.text = ""
			textView.textColor = .black
		}
	}
	
    func textViewDidChange(_ textView: UITextView) {
        saveButton.isEnabled = true
        saveButton.style = .done
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
			view.endEditing(true)
            return false
        } else {
            return true
        }
    }
    
    // MARK: - Text Field Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    
    // MARK: - Text Field Selectors
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        saveButton.isEnabled = true
    }
    
    // MARK: - Helper methods
	
	func logOut() {
		print("Attempting sign out...")
		if let currentWindow = UIApplication.shared.keyWindow {
			currentWindow.showLoadingIndicator(withMessage: "Cerrando sesión")
			if let _ = try? Auth.auth().signOut() {
				currentWindow.stopLoadingIndicator()
				print("Successfully signed out")
				// Purge keychain access
				if let _ = try? KeychainManager.deleteCredentials(credentials: KeychainManager.fetchCredentials()) {
					print("Successfully deleted credentials in Keychain")
				} else {
					print("Something went wrong deleting credentials in Keychain")
				}
				self.navigationController?.popToRootViewController(animated: true)
				
			} else {
				currentWindow.stopLoadingIndicator()
				print("Something went wrong")
				SCLAlertView().showWarning("Lo sentimos!", subTitle: "Intenta cerrar sesión en otro momento.")
			}
		}
	}
    
    func fillTextFields() {
        if let user = Global.localUser {
            firstNameField.text = user.firstName
            lastNameField.text = user.lastName
            emailField.text = user.email
            if user.bio != nil { bioTextView.text = user.bio }
            if user.city != nil { cityField.text = user.city }
            if user.state != nil { stateField.text = user.state }
        }
    }
	
	func setupTextFields() {
		firstNameField.delegate = self
		lastNameField.delegate = self
		emailField.delegate = self
		cityField.delegate = self
		stateField.delegate = self
		bioTextView.delegate = self
		
		firstNameField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
		lastNameField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
		emailField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
		cityField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
		stateField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
		
		emailField.isUserInteractionEnabled = false
	}
	
	func setupCancelEditingButton() {
		endEditingButton.frame = CGRect(x: 0, y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width, height: 50)
		endEditingButton.backgroundColor = UIColor(red: 74/255, green: 83/255, blue: 254/255, alpha: 1.0)
		endEditingButton.setAttributedTitle(NSAttributedString(string: "ESCONDER TECLADO",
													 attributes: [NSAttributedStringKey.font : UIFont(name: "Avenir-Medium",
																									  size: CGFloat(18))!,
																  NSAttributedStringKey.foregroundColor : UIColor.white]),
													 for: .normal)
		endEditingButton.addTarget(self, action: #selector(self.hideKeyboard), for: .touchUpInside)
		self.tableView.addSubview(endEditingButton)
	}
	
    @objc func keyboardWillShow(notification: NSNotification) {
		var keyboardHeight = CGFloat()
		if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
			let keyboardRectangle = keyboardFrame.cgRectValue
			keyboardHeight = keyboardRectangle.origin.y
		}
		UIButton.animate(withDuration: 0.3) {
			self.endEditingButton.frame = CGRect(x: 0, y: UIScreen.main.bounds.height-keyboardHeight, width: UIScreen.main.bounds.width, height: 60)
		}
        keyboardVisible = true
    }
	
    @objc func keyboardWillHide(notification: NSNotification) {
		UIButton.animate(withDuration: 0.3) {
			self.endEditingButton.frame = CGRect(x: 0, y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width, height: 60)
		}
        keyboardVisible = false
    }
	
    @objc func hideKeyboard() {
        if keyboardVisible {
          tableView.endEditing(true)
        }
    }
}

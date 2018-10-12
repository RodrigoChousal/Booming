//
//  SignUpViewController.swift
//  xMexico
//
//  Created by Development on 2/26/17.
//  Copyright © 2017 Rodrigo Chousal. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage

class SignUpViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
	
    @IBOutlet weak var formContentView: UIView!
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var showPasswordButton: UIButton!
    
    @IBOutlet weak var chooseImageButton: UIButton!
    @IBOutlet weak var pageController: SegmentedControl!
	
	// Interests View Buttons
	@IBOutlet weak var interestButton1: UIButton!
	@IBOutlet weak var interestButton2: UIButton!
	@IBOutlet weak var interestButton3: UIButton!
	@IBOutlet weak var interestButton4: UIButton!
	@IBOutlet weak var interestButton5: UIButton!
	@IBOutlet weak var interestButton6: UIButton!
	@IBOutlet weak var interestButton7: UIButton!
	@IBOutlet weak var interestButton8: UIButton!
	@IBOutlet weak var interestButton9: UIButton!
	@IBOutlet weak var interestButton10: UIButton!
	@IBOutlet weak var interestButton11: UIButton!
	@IBOutlet weak var interestButton12: UIButton!
	var interestButtons = [UIButton]()

    var keyboardVisible = false
    var imagePicker = UIImagePickerController()
    var chosenImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
		
		setupSwipeGestureRecognizers()
		
        imagePicker.delegate = self
		
        pageController.addTarget(self, action: #selector(segmentedControlValueChanged), for: .allEvents)
		
		setupButtonsList()
    }
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Sign Up Controls
    
    @IBAction func passwordVisibility(_ sender: Any) {
        if passwordField.isSecureTextEntry == true {
            showPasswordButton.setBackgroundImage(#imageLiteral(resourceName: "visible"), for: .normal)
            showPasswordButton.frame.size.height *= 3/4
            passwordField.isSecureTextEntry = false
            
        } else {
            showPasswordButton.setBackgroundImage(#imageLiteral(resourceName: "not_visible"), for: .normal)
            showPasswordButton.frame.size.height *= 4/3
            passwordField.isSecureTextEntry = true
        }
    }
    
    @IBAction func chooseProfilePicture(_ sender: Any) {
        
        let picker = self.imagePicker
        picker.delegate = self
        picker.sourceType = .savedPhotosAlbum
        picker.allowsEditing = true
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.savedPhotosAlbum){
            self.present(picker, animated: true, completion: nil)
        }
    }
    
    @IBAction func finishSignUp(_ sender: Any) {
        
        let formIncomplete = checkFormCompletion()
        
        if formIncomplete > 0 { // A field or payment is missing
            
            var missingField = ""

            switch formIncomplete {
                case 1:
                    missingField = "su primer nombre"
                case 2:
                    missingField = "su apellido"
                case 3:
                    missingField = "su correo electrónico"
                case 4:
                    missingField = "su contraseña"
                case 5:
                    missingField = "sus campañas de interés"
                default:
                    missingField = "sus datos"
            }
            
            SCLAlertView().showWarning("Ups!", subTitle: "Favor de ingresar \(missingField)")
            
        } else {
            
            // TODO: Show password strength!
            // TODO: Check for password errors... length, etc.
            view.showLoadingIndicator(withMessage: "Creando usuario...")
            
            let firstName = self.firstNameField.text!
            let lastName = self.lastNameField.text!
            let email = self.emailField.text!
            let password = self.passwordField.text!
			let interests = captureUserInterests()
			
            Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
                
                // Store user credentials in keychain
                let credentials = Credentials(email: email, password: password)
                KeychainManager.storeCredentials(credentials: credentials)
				
                if let fireUser = Auth.auth().currentUser, let img = self.chosenImage {
                    
                    // Store details locally:
                    Global.localUser = LocalUser(firstName: firstName,
                                                 lastName: lastName,
                                                 email: email,
												 dateCreated: Date(),
												 interests: interests,
												 backedCampaigns: [BackedCampaign]())
                    if let localUser = Global.localUser {
                        localUser.profilePicture = img
						localUser.backgroundPicture = #imageLiteral(resourceName: "placeholder") // TODO: Make background image placeholder
                    }
                    
                    // Store details in d cloud:
                    if let localUser = Global.localUser {
						SessionManager.populateFireUser(fireUser: fireUser, withLocalUser: localUser)
                    }
                    
                    // We're done
                    print("Finished sign up. Accessing main VC.")
                    DispatchQueue.main.async {
                        self.view.stopLoadingIndicator()
                        self.performSegue(withIdentifier: "AccessGranted", sender: self)
                    }
                    
                } else {
                    self.view.stopLoadingIndicator()
                    if let error = error {
                        SCLAlertView().showWarning("Ups!", subTitle: error.localizedDescription)
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.chosenImage = image
            let maskedImage = image.circleMasked!
            chooseImageButton.setBackgroundImage(maskedImage, for: .normal)
        } else{
            print("Something went wrong")
        }
        
        picker.dismiss(animated: true, completion: { () -> Void in })
    }
	
	// MARK: - Selector Methods
	
	@objc func interestSelected(sender: UIButton) {
		if let interest = CampaignType(rawValue: sender.titleLabel?.text ?? "") {
			if sender.backgroundColor == .white {
				let buttonAttributes = [NSAttributedStringKey.font : UIFont(name: "Avenir-Heavy",
																			size: CGFloat(16))!,
										NSAttributedStringKey.foregroundColor : UIColor.white]
				sender.setAttributedTitle(NSAttributedString(string: interest.rawValue,
															 attributes: buttonAttributes), for: .normal)
				sender.backgroundColor = .clear
			} else {
				let buttonAttributes = [NSAttributedStringKey.font : UIFont(name: "Avenir-Heavy",
																			size: CGFloat(16))!,
										NSAttributedStringKey.foregroundColor : UIColor.orange]
				sender.setAttributedTitle(NSAttributedString(string: interest.rawValue,
															 attributes: buttonAttributes), for: .normal)
				sender.backgroundColor = .white
			}
		}
	}
	
	@objc func segmentedControlValueChanged() {
		switch pageController.selectedIndex {
		case 0:
			changeFormContent(toIndex: 0)
		case 1:
			changeFormContent(toIndex: 1)
		case 2:
			changeFormContent(toIndex: 2)
		default:
			changeFormContent(toIndex: 0)
		}
	}
	
	@objc func swipeHandler(_ gestureRecognizer : UISwipeGestureRecognizer) {
		if gestureRecognizer.direction == .left {
			print("SWIPING LEFT")
			pageController.selectedIndex += 1
			segmentedControlValueChanged()
		} else if gestureRecognizer.direction == .right {
			print("SWIPING RIGHT")
			pageController.selectedIndex -= 1
			segmentedControlValueChanged()
		}
	}
	
	@objc func keyboardWillShow(notification: NSNotification) {
		keyboardVisible = true
	}
	
	@objc func keyboardWillHide(notification: NSNotification) {
		keyboardVisible = false
	}
	
	@objc func hideKeyboard() {
		if keyboardVisible {
			self.view.endEditing(true)
			keyboardVisible = false
		}
	}
    
    // MARK: - Helper Methods
	
	func setupSwipeGestureRecognizers() {
		let rightSwipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeHandler(_:)))
		rightSwipeRecognizer.direction = .right
		let leftSwipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeHandler(_:)))
		leftSwipeRecognizer.direction = .left
		view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
		view.addGestureRecognizer(rightSwipeRecognizer)
		view.addGestureRecognizer(leftSwipeRecognizer)
	}
	
	func setupButtonsList() { // The greatest sin in the history of computer programming
		interestButtons.append(interestButton1)
		interestButtons.append(interestButton2)
		interestButtons.append(interestButton3)
		interestButtons.append(interestButton4)
		interestButtons.append(interestButton5)
		interestButtons.append(interestButton6)
		interestButtons.append(interestButton7)
		interestButtons.append(interestButton8)
		interestButtons.append(interestButton9)
		interestButtons.append(interestButton10)
		interestButtons.append(interestButton11)
		interestButtons.append(interestButton12)
		
		var i = 0
		for button in interestButtons {
			button.addTarget(self, action: #selector(self.interestSelected(sender:)), for: .touchUpInside)
			button.backgroundColor = .clear
			button.layer.cornerRadius = 16
			button.layer.borderWidth = 3
			button.layer.borderColor = UIColor.white.cgColor
			button.setTitleColor(.white, for: .normal)
			let buttonAttributes = [NSAttributedStringKey.font : UIFont(name: "Avenir-Heavy",
																		size: CGFloat(16))!,
									NSAttributedStringKey.foregroundColor : UIColor.white]
			button.setAttributedTitle(NSAttributedString(string: CampaignType.allValues[i].rawValue,
														 attributes: buttonAttributes), for: .normal)
			i += 1
		}
	}
	
	func captureUserInterests() -> [CampaignType] {
		var userInterests = [CampaignType]()
		for button in interestButtons {
			if button.backgroundColor == .white {
				if let interest = CampaignType(rawValue: button.titleLabel?.text ?? "") {
					userInterests.append(interest)
				}
			}
		}
		return userInterests
	}
    
    func changeFormContent(toIndex index: Int) {
        UIView.animate(withDuration: 0.3) {
            self.formContentView.frame.origin.x = -self.formContentView.frame.size.width * CGFloat(index) / 3
        }
    }
    
    func checkFormCompletion() -> Int {
        
        let requiredFields = [firstNameField, lastNameField, emailField, passwordField]
		var missingFields = 0
		
        // Check if missing any required field
        for field in requiredFields {
            
            // TODO: Check for password and email validity
            
            if let text = field?.text, text.isEmpty { 
                return missingFields
            }
            missingFields += 1
        }
		
		var missingInterests = true
		for button in interestButtons {
			if button.backgroundColor == .white {
				missingInterests = false
			}
		}
		if missingInterests {
			missingFields = 5
			return missingFields
		}
		
        return 0
    }
}

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

    var keyboardVisible = false
    var imagePicker = UIImagePickerController()
    var chosenImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SignUpViewController.hideKeyboard)))
		
        imagePicker.delegate = self
        pageController.addTarget(self, action: #selector(self.segmentedControlValueChanged), for: .allEvents)
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
                    missingField = "un método de pago"
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
    
    // MARK: - Helper Methods
    
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
    
    func changeFormContent(toIndex index: Int) {
        UIView.animate(withDuration: 0.3) {
            self.formContentView.frame.origin.x = -self.formContentView.frame.size.width * CGFloat(index) / 3
        }
    }
    
    func checkFormCompletion() -> Int {
        
        let requiredFields = [firstNameField, lastNameField, emailField, passwordField]
        
        let missingPayment = false
        // TODO: Check if missing payment
        print(missingPayment)
        
        var count = 1
        
        // Check if missing any required field
        for field in requiredFields {
            
            // TODO: Check for password and email validity
            
            if let text = field?.text, text.isEmpty { 
                return count
            }
            count += 1
        }
        return 0
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
}

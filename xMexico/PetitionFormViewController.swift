//
//  PetitionFormViewController.swift
//  xMexico
//
//  Created by Development on 3/19/17.
//  Copyright © 2017 Rodrigo Chousal. All rights reserved.
//

import UIKit

class PetitionFormViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var campaignNameField: UITextField!
    @IBOutlet weak var campaignDescriptionTextView: UITextView!
    
    @IBOutlet weak var sendButton: UIButton!
    
    var keyboardVisible = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameField.delegate = self
        lastNameField.delegate = self
        emailField.delegate = self
        phoneField.delegate = self
        campaignNameField.delegate = self
        campaignDescriptionTextView.delegate = self
        
        nameField.isUserInteractionEnabled = false
        lastNameField.isUserInteractionEnabled = false
        emailField.isUserInteractionEnabled = false
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PetitionFormViewController.hideKeyboard)))
        
        navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedStringKey.foregroundColor: UIColor.black,
             NSAttributedStringKey.font: UIFont(name: "Avenir-Medium", size: 17)!]
                
        fillTextFields()
        
        setButtonShadow()
        
        self.automaticallyAdjustsScrollViewInsets = false
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelPetition(_ sender: Any) {
        self.dismiss(animated: true) {
            print("Dismissed petition form")
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Actions
    
    @IBAction func sendPetition(_ sender: Any) {
        
        if missingInfo() {
            
            SCLAlertView().showWarning("Datos incompletos", subTitle: "Favor de llenar la forma para poder enviar su petición.")
            
        } else {
            
            //FIXME: Método para enviar correo
            view.showLoadingIndicator(withMessage: "Enviando petición...")
        }
    }

    // MARK: - Helper Methods
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if !keyboardVisible {
                print("should scroll")
                
                print(keyboardSize.height)
                
                self.view.frame.origin.y -= keyboardSize.height
                
                let contentInsets = UIEdgeInsets(top: keyboardSize.height, left: 0, bottom: 0, right: 0)
                scrollView.contentInset = contentInsets
                scrollView.scrollIndicatorInsets = contentInsets
            }
        }
        
        keyboardVisible = true
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if keyboardVisible {
                
                self.view.frame.origin.y += keyboardSize.height
                
                scrollView.contentInset = UIEdgeInsets.zero
                scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
            }
        }
        
        keyboardVisible = false
    }
    
    @objc func hideKeyboard() {
        if keyboardVisible {
            view.endEditing(true)
        }
    }
    
    func fillTextFields() {
//        if let metadata = userMetadata {
//            nameField.text = metadata["first_name"] as? String
//            lastNameField.text = metadata["last_name"] as? String
//            emailField.text = userProfile.email
//        }
    }
    
    func missingInfo() -> Bool {
        
        if (nameField.text?.isEmpty)! || (lastNameField.text?.isEmpty)! || (emailField.text?.isEmpty)! || (phoneField.text?.isEmpty)! || (campaignNameField.text?.isEmpty)! || campaignDescriptionTextView.text.isEmpty {
            
            return true
            
        } else {
            
            return false
        }
    }
    
    func setButtonShadow() {
        sendButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        sendButton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        sendButton.layer.shadowOpacity = 1.0
        sendButton.layer.shadowRadius = 0.0
        sendButton.layer.masksToBounds = false
        sendButton.layer.cornerRadius = 4.0
    }
}

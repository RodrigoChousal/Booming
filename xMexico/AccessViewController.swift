//
//  AccessViewController.swift
//  xMexico
//
//  Created by Development on 2/25/17.
//  Copyright © 2017 Rodrigo Chousal. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseUI

var isVisitor = false

class AccessViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var titleImageView: UIImageView!
    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var showPasswordButton: UIButton!

    var buttonsViewPadding = CGFloat()
    var blurEffectView = UIView()
    var keyboardVisible = false
    var presentedFromLogout = false
    
    var newUser = true
        
    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .lightContent
        
        NotificationCenter.default.addObserver(self, selector: #selector(AccessViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AccessViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !newUser {
            print("User appears to be signed in...")
            // Show guests inside
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "AccessGranted", sender: self)
            }
        } else {
            print("User appears to not be signed in yet...")
        }
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(AccessViewController.hideKeyboard)))
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.backPressed(_:)))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.showLoginForm(_:)))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipeLeft)
                
        if !presentedFromLogout {
            
            let delayView = UIImageView(frame: view.frame) // delays for didFinishLaunching to find user profile
            delayView.image = #imageLiteral(resourceName: "launch")
            view.addSubview(delayView)
            
            Timer.scheduledTimer(withTimeInterval: 6.0, repeats: false) { (Timer) in
                self.animateCircularMask(view: delayView)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        blurEffectView.alpha = 0
        buttonsViewPadding = buttonsView.frame.origin.x
        
        if presentedFromLogout {
            emailField.text = ""
            passwordField.text = ""
            hideKeyboard()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .default
        
        NotificationCenter.default.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    @IBAction func unwindToAccessVC(segue: UIStoryboardSegue) {
        if let sourceViewController = segue.source as? MenuTVC {
            presentedFromLogout = sourceViewController.didLogout
        }
    }
    
    // MARK: - Login Controls
    
    @IBAction func showLoginForm(_ sender: Any) {
        if self.buttonsView.frame.origin.x >= 0 {
			self.buttonsViewPadding = self.buttonsView.frame.origin.x
            UIView.animate(withDuration: 0.3) {
				self.buttonsView.frame.origin.x -= self.buttonsView.frame.width/2 + self.buttonsViewPadding
            }
        }
    }
    
    @IBAction func backPressed(_ sender: Any) {
        if self.buttonsView.frame.origin.x < 0 {
            UIView.animate(withDuration: 0.3) {
				self.buttonsView.frame.origin.x += self.buttonsView.frame.width/2 + self.buttonsViewPadding
            }
        }
    }
    
    @IBAction func showPassword(_ sender: Any) {
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
    
    @IBAction func login(_ sender: Any) {

        self.resignFirstResponder()
        
        let accessEmail = emailField.text ?? ""
        let accessPassword = passwordField.text ?? ""
        
        // TODO: Check valid email address
        if !accessEmail.isEmpty && !accessPassword.isEmpty { // Fields are complete
            
            view.showLoadingIndicator(withMessage: "Iniciando sesión...")
            self.buttonsView.isUserInteractionEnabled = false
            
            Auth.auth().signIn(withEmail: accessEmail, password: accessPassword) { (dataResult, error) in
                if let error = error { // Login failed
                    
                    // Print error and display alert
                    print(error)
                    DispatchQueue.main.async {
                        SCLAlertView().showError("Oops!", subTitle: "Username or password entered is incorrect.")
                        self.view.stopLoadingIndicator()
                        self.buttonsView.isUserInteractionEnabled = true
                    }

                } else { // Login successful
					
					// Store user credentials in keychain
					let credentials = Credentials(email: accessEmail, password: accessPassword)
					KeychainManager.storeCredentials(credentials: credentials)
                    
                    // Store important user data
                    if let fireUser = Auth.auth().currentUser {
                        SessionManager.populateLocalUser(withFireUser: fireUser)
                    }
                    
                    // Show guests inside
                    DispatchQueue.main.async {
                        self.view.stopLoadingIndicator()
                        self.performSegue(withIdentifier: "AccessGranted", sender: self)
                    }

                }
            }
            
        } else { // Some empty fields
            view.endEditing(true)
            SCLAlertView().showWarning("Ups!", subTitle: "Asegúrate de llenar ambos campos.")
        }
    }
    
    @IBAction func enterAsVisitor(_ sender: Any) {
        isVisitor = true
    }
    
    @IBAction func signUp(_ sender: Any) {
        
    }
    
    // MARK: - Helper Methods
    
    func blurScreen() {
        let blurEffect = UIBlurEffect(style: .dark)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.alpha = 1.0
        view.addSubview(blurEffectView)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if !keyboardVisible {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
        
        keyboardVisible = true
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if keyboardVisible {
            self.view.frame.origin.y = 0
        }
        keyboardVisible = false
    }
    
    @objc func hideKeyboard() {
        
        if keyboardVisible {
            self.view.endEditing(true)
            keyboardVisible = false
        }
    }

    func animateCircularMask(view: UIImageView) {
        
        let viewDiagonal = sqrt(view.frame.height * view.frame.height + view.frame.width * view.frame.width)
        let circleRadius = viewDiagonal/2
        
        let circle = UIView(frame: CGRect(x: 0, y: 0, width: viewDiagonal, height: viewDiagonal))
        circle.backgroundColor = UIColor.yellow
        circle.layer.cornerRadius = circleRadius
        circle.layer.borderWidth = 2.0
        circle.layer.borderColor = UIColor.red.cgColor
        
        circle.center = view.center
        
        view.mask = circle

        UIView.animate(withDuration: 0.5, delay: 0.01, options: .curveLinear, animations: {
            circle.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        }, completion: { (Bool) in
            view.removeFromSuperview()
        })
    }
}


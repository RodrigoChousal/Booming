//
//  MatchmakingVC.swift
//  xMexico
//
//  Created by Rodrigo Chousal on 10/15/18.
//  Copyright © 2018 Rodrigo Chousal. All rights reserved.
//

import UIKit
import FirebaseAuth

class MatchmakingVC: UIViewController {

	@IBOutlet weak var menuButton: UIBarButtonItem!
	
	var interestButtons = [UIButton]()
	var saveButton = UIButton(type: .system)
	var selectedInterests = [CampaignType]()
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		setupMenu()
		
		if let localUser = Global.localUser {
			selectedInterests = localUser.interests
		}

		createButtonInstances()
		arrangeButtonInstances()
    }
	
	// MARK: - Selectors
	
	@objc func interestSelected(sender: UIButton) {
		
		let feedback = UIImpactFeedbackGenerator(style: .light)
		feedback.impactOccurred()
		
		if let interest = CampaignType(rawValue: sender.titleLabel?.text ?? "") {
			if sender.backgroundColor == Global.atomicBlue {
				let buttonAttributes = [NSAttributedStringKey.font : UIFont(name: "Avenir-Heavy",
																			size: CGFloat(16))!,
										NSAttributedStringKey.foregroundColor : Global.atomicBlue]
				sender.setAttributedTitle(NSAttributedString(string: interest.rawValue,
															 attributes: buttonAttributes), for: .normal)
				sender.backgroundColor = .clear
			} else {
				let buttonAttributes = [NSAttributedStringKey.font : UIFont(name: "Avenir-Heavy",
																			size: CGFloat(16))!,
										NSAttributedStringKey.foregroundColor : UIColor.white]
				sender.setAttributedTitle(NSAttributedString(string: interest.rawValue,
															 attributes: buttonAttributes), for: .normal)
				sender.backgroundColor = Global.atomicBlue
			}
		}
		
		selectedInterests = captureUserInterests()
	}
	
	@objc func saveInterestsPressed() {
		view.showLoadingIndicator(withMessage: "Guardando...")
		if let localUser = Global.localUser, let fireUser = Auth.auth().currentUser {
			localUser.interests = selectedInterests
			SessionManager.updateFireUser(fireUser: fireUser, withLocalUser: localUser) // TODO: Very inefficient, should only update interests instead of entire profile
			view.stopLoadingIndicator()
			let atomicAlert = AtomicAlertView(title: "Listo", message: "Intereses guardados exitosamente")
			atomicAlert.show(animated: true)
		}
	}
	
	// MARK: - Helper Methods
	
	func setupMenu() {
		if revealViewController() != nil {
			menuButton.target = self.revealViewController()
			menuButton.action = #selector((SWRevealViewController.revealToggleMenu) as (SWRevealViewController) -> (Any?) -> Void) as Selector
			view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
			view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
		}
	}
	
	func createButtonInstances() {
		
		for type in CampaignType.allValues {
			if type != .DEFAULT {
				let interestButton = UIButton(type: .custom)
				interestButton.addTarget(self, action: #selector(self.interestSelected(sender:)), for: .touchUpInside)
				interestButton.layer.cornerRadius = 16
				interestButton.layer.borderWidth = 3
				interestButton.layer.borderColor = Global.atomicBlue.cgColor
				var buttonAttributes = [NSAttributedStringKey.font : UIFont(name: "Avenir-Heavy",
																			size: CGFloat(16))!,
										NSAttributedStringKey.foregroundColor : UIColor.white]
				if selectedInterests.contains(type) {
					interestButton.backgroundColor = Global.atomicBlue
					buttonAttributes[.foregroundColor] = UIColor.white
				} else {
					interestButton.backgroundColor = .clear
					buttonAttributes[.foregroundColor] = Global.atomicBlue
				}
				interestButton.setAttributedTitle(NSAttributedString(string: type.rawValue,
																	 attributes: buttonAttributes), for: .normal)
				
				interestButtons.append(interestButton)
			}
		}
		
		saveButton.addTarget(self, action: #selector(self.saveInterestsPressed), for: .touchUpInside)
		saveButton.backgroundColor = .green
		saveButton.layer.cornerRadius = 16
		saveButton.setTitleColor(.white, for: .normal)
		saveButton.setTitle("Guardar", for: .normal)
	}
	
	func arrangeButtonInstances() {
		let xInset = CGFloat(16)
		let yInset = CGFloat(100)
		let xPadding = CGFloat(20)
		let yPadding = CGFloat(20)
		let buttonWidth = (UIScreen.main.bounds.width - xInset * 2 - xPadding)/2
		let buttonHeight = CGFloat(60)
		
		var i = 0
		for button in interestButtons {
			if i % 2 == 1 {
				button.frame = CGRect(x: xInset, y: (yInset + (buttonHeight + yPadding) * CGFloat(i/2)),
									  width: buttonWidth, height: buttonHeight)
			} else {
				button.frame = CGRect(x: xInset + buttonWidth + xPadding,
									  y: (yInset + (buttonHeight + yPadding) * CGFloat(i/2)),
									  width: buttonWidth, height: buttonHeight)
			}
			
			view.addSubview(button)
			
			i += 1
		}
		
		let saveButtonY = yInset + CGFloat(interestButtons.count/2)*(buttonHeight + yPadding)
		let saveButtonWidth = UIScreen.main.bounds.width - xInset * 2
		saveButton.frame = CGRect(x: xInset, y: saveButtonY, width: saveButtonWidth, height: buttonHeight)
		view.addSubview(saveButton)
	}
	
	func captureUserInterests() -> [CampaignType] {
		var userInterests = [CampaignType]()
		for button in interestButtons {
			if button.backgroundColor == Global.atomicBlue {
				if let interest = CampaignType(rawValue: button.titleLabel?.text ?? "") {
					userInterests.append(interest)
				}
			}
		}
		return userInterests
	}
}

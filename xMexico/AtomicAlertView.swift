//
//  AtomicAlertView.swift
//  xMexico
//
//  Created by Rodrigo Chousal on 9/26/18.
//  Copyright © 2018 Rodrigo Chousal. All rights reserved.
//

import UIKit

class AtomicAlertView: UIView {
	
	var backgroundView = UIView()
	var dialogView = UIView()
	
	var title: String = String()
	var message: String = String()
	var actionButtons: [UIButton] = [UIButton]()
	
	// Constants
	let horizontalPaddingOut = CGFloat(32)
	let horizontalPaddingIn = CGFloat(16)
	let verticalPaddingIn = CGFloat(8)
	let dialogViewWidth = UIScreen.main.bounds.width - CGFloat(64) // TODO: Hate hardcoded values
	let dialogSubviewHeight = CGFloat(30)
	let buttonHeight = CGFloat(50)
	
	// Layout Helper
	var currentY = CGFloat(8)
	
	convenience init(title: String, message: String) {
		
		self.init(frame: UIScreen.main.bounds)
		
		self.title = title
		self.message = message
		
		let okButton = UIButton(type: .system)
		okButton.setTitle("OK", for: .normal)
		okButton.backgroundColor = UIColor(red: 74/255, green: 83/255, blue: 254/255, alpha: 1.0)
		okButton.setTitleColor(.white, for: .normal)
		okButton.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
		
		setupBackgroundView()
		setupTitle()
		insertSeparator()
		setupMessage()
		setupButtons(actionButtons: [okButton])
		setupDialogView(withHeight: currentY)
	}
	
	convenience init(title: String, linkForCopy link: String) {
		
		self.init(frame: UIScreen.main.bounds)
		
		self.title = title
		self.message = link
		
		let copyButton = UIButton(type: .system)
		copyButton.setTitle("COPIAR", for: .normal)
		copyButton.backgroundColor = UIColor(red: 74/255, green: 83/255, blue: 254/255, alpha: 1.0)
		copyButton.setTitleColor(.white, for: .normal)
		copyButton.addTarget(self, action: #selector(copyMessage), for: .touchUpInside)
		
		setupBackgroundView()
		setupTitle()
		insertSeparator()
		setupLink()
		setupButtons(actionButtons: [copyButton])
		setupDialogView(withHeight: currentY)
	}
	
	convenience init(title: String, message: String, actionButtons: [UIButton]) {
		
		self.init(frame: UIScreen.main.bounds)
		
		self.title = title
		self.message = message
		self.actionButtons = actionButtons
		
		setupBackgroundView()
		setupTitle()
		insertSeparator()
		setupMessage()
		setupButtons(actionButtons: actionButtons)
		setupDialogView(withHeight: currentY)
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	// MARK: - Helper Methods
	
	func setupBackgroundView() {
		// Encompasses whole screen, to darken screen when presented
		backgroundView.frame = frame
		backgroundView.backgroundColor = UIColor.black
		backgroundView.alpha = 0.6
		backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismiss)))
		addSubview(backgroundView)
	}
	
	func setupDialogView(withHeight height: CGFloat) {
		// Begins below view, ready for animation
		let dialogViewHeight = height
		dialogView.clipsToBounds = true
		dialogView.frame.origin = CGPoint(x: 32, y: frame.height)
		dialogView.frame.size = CGSize(width: frame.width-64, height: dialogViewHeight)
		dialogView.backgroundColor = UIColor.white
		dialogView.layer.cornerRadius = 6
		addSubview(dialogView)
	}
	
	func setupTitle() {
		let titleLabel = UILabel(frame: CGRect(x: 0, y: currentY, width: dialogViewWidth, height: dialogSubviewHeight))
		titleLabel.font = UIFont(name: "Avenir-Medium", size: CGFloat(20))
		titleLabel.text = self.title
		titleLabel.textAlignment = .center
		dialogView.addSubview(titleLabel)
		
		currentY += titleLabel.frame.height + verticalPaddingIn
	}
	
	func insertSeparator() {
		let separatorLineView = UIView(frame: CGRect(x: 0, y: currentY, width: dialogViewWidth, height: 1))
		separatorLineView.backgroundColor = UIColor.groupTableViewBackground
		dialogView.addSubview(separatorLineView)
		
		currentY += separatorLineView.frame.height + verticalPaddingIn
	}
	
	func setupMessage() {
		let messageLabel = UILabel(frame: CGRect(x: 0, y: currentY, width: dialogViewWidth, height: dialogSubviewHeight))
		messageLabel.text = message
		messageLabel.textAlignment = .center
		dialogView.addSubview(messageLabel)
		
		currentY += messageLabel.frame.height + verticalPaddingIn
	}
	
	func setupLink() {
		let linkTextField = UITextField(frame: CGRect(x: horizontalPaddingIn, y: currentY, width: dialogViewWidth - horizontalPaddingIn*2, height: dialogSubviewHeight))
		linkTextField.backgroundColor = UIColor(red: 41/255, green: 41/255, blue: 41/255, alpha: 1.0)
		linkTextField.text = message
		linkTextField.textColor = .white
		linkTextField.font = UIFont(name: "Menlo-Regular", size: 16)
		linkTextField.textAlignment = .center
		dialogView.addSubview(linkTextField)
		
		currentY += linkTextField.frame.height + verticalPaddingIn
	}
	
	func setupButtons(actionButtons: [UIButton]) {
		var actionsContainerView = UIView()
		if actionButtons.count == 2 {
			actionsContainerView = UIView(frame: CGRect(x: 0, y: currentY, width: dialogViewWidth, height: buttonHeight))
			actionButtons[0].frame = CGRect(x: 0, y: 0, width: dialogViewWidth/2, height: buttonHeight)
			actionButtons[0].addTarget(self, action: #selector(dismiss), for: .touchUpInside)
			actionsContainerView.addSubview(actionButtons[0])
			actionButtons[1].frame = CGRect(x: dialogViewWidth/2, y: 0, width: dialogViewWidth/2, height: buttonHeight)
			actionButtons[1].addTarget(self, action: #selector(dismiss), for: .touchUpInside)
			actionsContainerView.addSubview(actionButtons[1])
		} else {
			actionsContainerView = UIView(frame: CGRect(x: 0, y: currentY, width: dialogViewWidth, height: CGFloat(actionButtons.count) * buttonHeight))
			var dynamicHeight = CGFloat(0)
			for button in actionButtons {
				button.frame = CGRect(x: 0, y: 0, width: dialogViewWidth, height: buttonHeight)
				dynamicHeight += buttonHeight
				actionsContainerView.addSubview(button)
			}
		}
		dialogView.addSubview(actionsContainerView)
		
		currentY += actionsContainerView.frame.height
	}
	
	@objc func copyMessage(sender: UIButton) {
		UIPasteboard.general.string = self.message
		sender.setTitle("Link copied to clipboard", for: .normal)
		sender.isEnabled = false
	}
	
	// MARK: - Presentation & Dismissal
	
	func show(animated: Bool) {
		self.backgroundView.alpha = 0
		self.dialogView.center = CGPoint(x: self.center.x, y: self.frame.height + self.dialogView.frame.height/2)
		if let window = UIApplication.shared.keyWindow {
			window.addSubview(self)
			if animated {
				UIView.animate(withDuration: 0.33, animations: {
					self.backgroundView.alpha = 0.66
				})
				UIView.animate(withDuration: 0.33, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 10, options: UIViewAnimationOptions(rawValue: 0), animations: {
					self.dialogView.center  = self.center
				}, completion: { (completed) in
					
				})
			} else {
				self.backgroundView.alpha = 0.66
				self.dialogView.center  = self.center
			}
		}
	}
	
	@objc func dismiss() {
		UIView.animate(withDuration: 0.33, animations: {
			self.backgroundView.alpha = 0
		}, completion: { (completed) in
			
		})
		UIView.animate(withDuration: 0.33, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 10, options: UIViewAnimationOptions(rawValue: 0), animations: {
			self.dialogView.center = CGPoint(x: self.center.x, y: self.frame.height + self.dialogView.frame.height/2)
		}, completion: { (completed) in
			self.removeFromSuperview()
		})
	}
}

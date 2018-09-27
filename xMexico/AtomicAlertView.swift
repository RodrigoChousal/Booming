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
	
	convenience init(title: String, link: String) {
		self.init(frame: UIScreen.main.bounds)
		initialize(title: title, link: link)
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	func initialize(title: String, link: String){
		
		// Constants
		let viewPadding = CGFloat(32)
		
		dialogView.clipsToBounds = true
		
		backgroundView.frame = frame
		backgroundView.backgroundColor = UIColor.black
		backgroundView.alpha = 0.6
		backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTappedOnBackgroundView)))
		addSubview(backgroundView)
		
		let dialogViewWidth = frame.width - (viewPadding * 2)
		
		let titleLabel = UILabel(frame: CGRect(x: 8, y: 8, width: dialogViewWidth-16, height: 30))
		titleLabel.text = title
		titleLabel.textAlignment = .center
		dialogView.addSubview(titleLabel)
		
		let separatorLineView = UIView()
		separatorLineView.frame.origin = CGPoint(x: 0, y: titleLabel.frame.height + 8)
		separatorLineView.frame.size = CGSize(width: dialogViewWidth, height: 1)
		separatorLineView.backgroundColor = UIColor.groupTableViewBackground
		dialogView.addSubview(separatorLineView)
		
		let linkTextField = UITextField(frame: CGRect(x: 8, y: 8 + titleLabel.frame.height + 8 + separatorLineView.frame.height + 8, width: dialogViewWidth - 16, height: 30))
		linkTextField.backgroundColor = .gray
		linkTextField.text = link
		linkTextField.textColor = .white
		linkTextField.font = UIFont(name: "Menlo-Regular", size: 16)
		linkTextField.textAlignment = .center
		dialogView.addSubview(linkTextField)
		
		let dialogViewHeight = titleLabel.frame.height + 8 + separatorLineView.frame.height + 8 + linkTextField.frame.height + 16
		
		dialogView.frame.origin = CGPoint(x: 32, y: frame.height)
		dialogView.frame.size = CGSize(width: frame.width-64, height: dialogViewHeight)
		dialogView.backgroundColor = UIColor.white
		dialogView.layer.cornerRadius = 6
		addSubview(dialogView)
	}
	
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
	
	func dismiss(animated: Bool) {
		if animated {
			UIView.animate(withDuration: 0.33, animations: {
				self.backgroundView.alpha = 0
			}, completion: { (completed) in
				
			})
			UIView.animate(withDuration: 0.33, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 10, options: UIViewAnimationOptions(rawValue: 0), animations: {
				self.dialogView.center = CGPoint(x: self.center.x, y: self.frame.height + self.dialogView.frame.height/2)
			}, completion: { (completed) in
				self.removeFromSuperview()
			})
		} else {
			self.removeFromSuperview()
		}
	}
	
	@objc func didTappedOnBackgroundView(){
		dismiss(animated: true)
	}
}

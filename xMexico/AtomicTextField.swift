//
//  AtomicTextField.swift
//  xMexico
//
//  Created by Rodrigo Chousal on 10/15/18.
//  Copyright © 2018 Rodrigo Chousal. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class AtomicTextField: UITextField {
	
	let imagePadding = CGFloat(10)
	let imageWidth = CGFloat(20)
	let imageHeight = CGFloat(20)
	
	var padding: UIEdgeInsets {
		return UIEdgeInsets(top: 0, left: (imagePadding + imageWidth + imagePadding), bottom: 0, right: 5)
	}
	
	override open func textRect(forBounds bounds: CGRect) -> CGRect {
		return UIEdgeInsetsInsetRect(bounds, padding)
	}
	
	override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
		return UIEdgeInsetsInsetRect(bounds, padding)
	}
	
	override open func editingRect(forBounds bounds: CGRect) -> CGRect {
		return UIEdgeInsetsInsetRect(bounds, padding)
	}
	
	// Provides left padding for images
	override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
		var textRect = super.leftViewRect(forBounds: bounds)
		textRect.origin.x += imagePadding
		return textRect
	}
	
	@IBInspectable var leftImage: UIImage? {
		didSet {
			updateView()
		}
	}
	
	func updateView() {
		
		if let image = leftImage {
			leftViewMode = .always
			let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight))
			imageView.contentMode = .scaleAspectFit
			imageView.image = image
			// Note: In order for your image to use the tint color, you have to select the image in the Assets.xcassets and change the "Render As" property to "Template Image".
			imageView.tintColor = self.tintColor
			leftView = imageView
		} else {
			leftViewMode = UITextFieldViewMode.never
			leftView = nil
		}
		
		// Placeholder text color
		attributedPlaceholder = NSAttributedString(string: placeholder != nil ?  placeholder! : "", attributes:[NSAttributedStringKey.foregroundColor: UIColor(red: 205/255, green: 205/255, blue: 205/255, alpha: 1.0)])
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.leftViewMode = .always
		self.layer.cornerRadius = 8
		self.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1.0)
		self.font = UIFont(name: "Avenir-Medium", size: 16)
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
	}
}

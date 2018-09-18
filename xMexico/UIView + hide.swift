//
//  UIView + hide.swift
//  xMexico
//
//  Created by Rodrigo Chousal on 9/11/18.
//  Copyright © 2018 Rodrigo Chousal. All rights reserved.
//

import Foundation

extension UIView {
	func hide(duration: TimeInterval) {
		let hiderView = UIView(frame: UIScreen.main.bounds)
		hiderView.backgroundColor = .blue
		self.addSubview(hiderView)
		UIView.animate(withDuration: duration) {
			hiderView.alpha = 0.0
		}
	}
}

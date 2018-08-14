//
//  UIView + showLoadingIndicator.swift
//  xMexico
//
//  Created by Development on 4/7/17.
//  Copyright © 2017 Rodrigo Chousal. All rights reserved.
//

import Foundation

extension UIView {
    
    func showLoadingIndicator(withMessage message: String) {
        
        let blurEffect = UIBlurEffect(style: .dark)
        
        let indicatorView = UIVisualEffectView(effect: blurEffect)
        indicatorView.accessibilityIdentifier = "LoadingIndicator"
        
        indicatorView.frame = CGRect(x: self.frame.size.width/4, y: self.frame.size.height/3, width: self.frame.size.width/2, height: self.frame.size.height/4)
        indicatorView.alpha = 1.0
        indicatorView.layer.cornerRadius = 20
        indicatorView.clipsToBounds = true
        
        let indicator = MaterialLoadingIndicator(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        indicator.center = CGPoint(x: indicatorView.frame.width/2, y: indicatorView.frame.height/2)
        
        let infoLabel = UILabel(frame: CGRect(x: 0, y: indicatorView.frame.height*5/6 - 10, width: indicatorView.frame.width, height: indicatorView.frame.height/6))
        infoLabel.text = message
        infoLabel.font = UIFont(name: "Avenir-medium", size: 18)
        infoLabel.textColor = .white
        infoLabel.textAlignment = .center
        
        indicatorView.contentView.addSubview(indicator)
        indicatorView.contentView.addSubview(infoLabel)
        
        indicator.startAnimating()
        
        self.addSubview(indicatorView)
    }
    
    func stopLoadingIndicator() {
        DispatchQueue.main.async {
            for view in self.subviews {
                if view.accessibilityIdentifier == "LoadingIndicator" {
                    view.removeFromSuperview()
                }
            }
        }
    }
}

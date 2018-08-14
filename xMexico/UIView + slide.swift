//
//  UIView + slide.swift
//  xMexico
//
//  Created by Development on 2/26/17.
//  Copyright © 2017 Rodrigo Chousal. All rights reserved.
//

import Foundation

extension UIView {
    
    func slideHorizontally(by translation: CGFloat, for duration: TimeInterval) {
        self.transform = CGAffineTransform(translationX: translation, y: 0)
        
        UIView.animate(withDuration: duration,
                       delay: 0.0,
                       options: UIViewAnimationOptions.curveEaseInOut,
                       animations: {
                        self.transform = CGAffineTransform.identity
        }, completion: {finished in
        })
    }
}

//
//  SlideLeftSegue.swift
//  xMexico
//
//  Created by Development on 2/26/17.
//  Copyright © 2017 Rodrigo Chousal. All rights reserved.
//

import UIKit

class SlideLeftSegue: UIStoryboardSegue {
	
    override func perform() {
        
        source.view.addSubview(destination.view)
//        source.view.transform = CGAffineTransform(translationX: source.view.frame.size.width, y: 0)
        destination.view.transform = CGAffineTransform(translationX: source.view.frame.size.width, y: 0)
        
        UIView.animate(withDuration: 0.25,
                       delay: 0.0,
                       options: UIViewAnimationOptions.curveEaseInOut,
                       animations: {
                        self.destination.view.transform = CGAffineTransform.identity
        }, completion: {finished in
            self.source.present(self.destination, animated: false, completion: nil)
        })
    }

}

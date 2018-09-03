//
//  CustomSearchBar.swift
//  xMexico
//
//  Created by Development on 6/23/17.
//  Copyright © 2017 Rodrigo Chousal. All rights reserved.
//

import UIKit

class CustomSearchBar: UISearchBar {
    
    var preferredFont: UIFont!
    var preferredTextColor: UIColor!
    
    init(frame: CGRect, font: UIFont, textColor: UIColor) {
        super.init(frame: frame)
		
		let attributes : [NSAttributedStringKey : Any] = [
			NSAttributedStringKey.foregroundColor : UIColor.black,
			NSAttributedStringKey.font : UIFont(name: "Avenir-Light", size: 16.0) ?? UIFont.systemFont(ofSize: 16.0)
		]
		UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes(attributes, for: .normal)
        self.frame = frame
        preferredFont = font
        preferredTextColor = textColor
        
        searchBarStyle = .prominent
        isTranslucent = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func indexOfSearchFieldInSubviews() -> Int! {
        var index: Int!
        let searchBarView = subviews[0] 
        
        for i in 0 ..< searchBarView.subviews.count {
            if searchBarView.subviews[i].isKind(of: UITextField.self) {
                index = i
                break
            }
        }
        
        return index
    }
    
    override func draw(_ rect: CGRect) {

        if let index = indexOfSearchFieldInSubviews() {

            let searchField: UITextField = subviews[0].subviews[index] as! UITextField
            searchField.frame = CGRect(x: 5.0, y: 5.0, width: frame.size.width - 10.0, height: frame.size.height - 10.0)
            
            searchField.font = preferredFont
            searchField.textColor = preferredTextColor
            
            searchField.backgroundColor = barTintColor
        }
        
        let startPoint = CGPoint(x: 0.0, y: frame.size.height)
        let endPoint = CGPoint(x: frame.size.width, y: frame.size.height)
        let path = UIBezierPath()
        path.move(to: startPoint)
        path.addLine(to: endPoint)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = preferredTextColor.cgColor
        shapeLayer.lineWidth = 2.5
        
        layer.addSublayer(shapeLayer)
        
        super.draw(rect)
    }

}

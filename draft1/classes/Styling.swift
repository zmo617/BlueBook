//
//  Styling.swift
//  draft1
//
//  Created by Claire Mo on 7/2/20.
//  Copyright © 2020 Zongying Mo. All rights reserved.
//

import Foundation
import UIKit

class Styling{
    //code from internet
    static func styleTextField(_ textfield:UITextField) {
        // Create the bottom line
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0, y: textfield.frame.height - 2, width: textfield.frame.width, height: 2)
        //bottomLine.backgroundColor = UIColor.init(red: 48/255, green: 173/255, blue: 99/255, alpha: 1).cgColor
        // Remove border on text field
        textfield.borderStyle = .none
        bottomLine.backgroundColor = UIColor.white.cgColor
        // Add the line to the text field
        textfield.layer.addSublayer(bottomLine)
        textfield.attributedPlaceholder = NSAttributedString(string: textfield.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray2])
        textfield.textColor = UIColor.white
    }
    
    static func styleFilledButton(_ button:UIButton) {
        // Filled rounded corner style
        //button.backgroundColor = UIColor.init(red: 48/255, green: 173/255, blue: 99/255, alpha: 1)
        button.layer.cornerRadius = 25.0
        button.tintColor = UIColor.white
    }
    
    static func styleHollowButton(_ button:UIButton) {
        // Hollow rounded corner style
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.white.cgColor
        //button.layer.cornerRadius = 25.0
        button.tintColor = UIColor.white
    }
    
    static func styleFilledRoundButton(_ button:UIButton){
        button.layer.cornerRadius = button.frame.size.width / 2
        button.backgroundColor = UIColor.appBlue
        button.tintColor = UIColor.white
    }
    
    static func setBg(vc: UIViewController, imgName: String){
            let bgView = UIImageView()
        let view = vc.view
        view!.addSubview(bgView)
            bgView.translatesAutoresizingMaskIntoConstraints = false
            bgView.image = UIImage(named: imgName)
            bgView.contentMode = .top
            bgView.alpha = 0.7
            NSLayoutConstraint.activate([
                bgView.topAnchor.constraint(equalTo: view!.topAnchor),
                bgView.bottomAnchor.constraint(equalTo: view!.bottomAnchor),
                bgView.leadingAnchor.constraint(equalTo: view!.leadingAnchor),
                bgView.trailingAnchor.constraint(equalTo: view!.trailingAnchor)
            ])
            view!.sendSubviewToBack(bgView)
    }
}

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
    static func navDarkMode(vc: UIViewController){
        let navBar = vc.navigationController?.navigationBar
        navBar?.barTintColor = .appBlue //bg
        navBar?.tintColor = .white //items
        navBar?.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }
    
    static func navDayMode(vc: UIViewController){
        let navBar = vc.navigationController?.navigationBar
        navBar?.barTintColor = .white //bg
        navBar?.tintColor = .appBlue //items
        navBar?.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.appBlue]
        
    }
    
    static func styleTextField(_ textfield:UITextField) {
        // Create the bottom line
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0, y: textfield.frame.height - 2, width: textfield.frame.width, height: 2)
        // Remove border on text field
        textfield.borderStyle = .none
        bottomLine.backgroundColor = UIColor.white.cgColor
        // Add the line to the text field
        textfield.layer.addSublayer(bottomLine)
        textfield.attributedPlaceholder = NSAttributedString(string: textfield.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray2])
        textfield.textColor = UIColor.white
    }
    
    static func dayTextField(_ textfield:UITextField) {
        // Create the bottom line
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0, y: textfield.frame.height - 2, width: textfield.frame.width, height: 2)
        // Remove border on text field
        textfield.borderStyle = .none
        bottomLine.backgroundColor = UIColor.white.cgColor
        // Add the line to the text field
        textfield.layer.addSublayer(bottomLine)
        textfield.attributedPlaceholder = NSAttributedString(string: textfield.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray2])
        textfield.textColor = .black
    }
    
    static func underlineLabel(_ label: UILabel){
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0, y: label.frame.height - 2, width: label.frame.width, height: 2)
        // Remove border on text field
        bottomLine.backgroundColor = UIColor.white.cgColor
        // Add the line to the text field
        label.layer.addSublayer(bottomLine)
        label.textColor = UIColor.white
    }
    
    static func styleFilledButton(_ button:UIButton, _ cornerRad: CGFloat) {
        // Filled rounded corner style
        button.backgroundColor = .white
        button.layer.cornerRadius = cornerRad
        button.tintColor = .appBlue
        button.titleLabel?.textColor = .appBlue
    }
    
    static func dayFilledButton(_ button:UIButton, _ cornerRad: CGFloat) {
        // Filled rounded corner style
        button.backgroundColor = .appBlue
        button.layer.cornerRadius = cornerRad
        button.tintColor = .black
        button.titleLabel?.textColor = .black
    }
    
    static func styleHollowButton(_ button:UIButton, _ fontSize: CGFloat) {
        // Hollow rounded corner style
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.white.cgColor
        button.titleLabel?.font = UIFont(name: "Apple Color Emoji", size: fontSize)
        button.tintColor = UIColor.white
        button.titleLabel?.textColor = .white
    }
    
    static func dayHollowButton(_ button:UIButton, _ fontSize: CGFloat) {
        // Hollow rounded corner style
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.black.cgColor
        button.titleLabel?.font = UIFont(name: "Apple Color Emoji", size: fontSize)
        button.tintColor = UIColor.black
        button.titleLabel?.textColor = .black
    }
    
    static func styleFilledRoundButton(_ button:UIButton){
        button.layer.cornerRadius = button.frame.size.width / 2
        button.backgroundColor = .white
        button.tintColor = .appBlue
    }
    
    static func setUpBg(vc: UIViewController, imgName: String) -> UIImageView{
        let imgView = UIImageView()
        let view = vc.view
        view!.addSubview(imgView)
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.image = UIImage(named: imgName)
        imgView.contentMode = .top
        imgView.alpha = 0.7
        NSLayoutConstraint.activate([
            imgView.topAnchor.constraint(equalTo: view!.topAnchor),
            imgView.bottomAnchor.constraint(equalTo: view!.bottomAnchor),
            imgView.leadingAnchor.constraint(equalTo: view!.leadingAnchor),
            imgView.trailingAnchor.constraint(equalTo: view!.trailingAnchor)
        ])
        view!.sendSubviewToBack(imgView)
        return imgView
    }
    
    static func errorAlert(vc: UIViewController, msg: String){
        let controller = UIAlertController(title: "Error", message: msg, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        vc.present(controller, animated: true, completion: nil)
    }
}

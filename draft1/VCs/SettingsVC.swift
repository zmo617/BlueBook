//
//  SettingsVC.swift
//  draft1
//
//  Created by Kevin Diep on 6/16/20.
//  Copyright © 2020 Zongying Mo. All rights reserved.
//

import UIKit

class SettingsVC: UIViewController {

    @IBOutlet weak var signOutBtn: UIButton!
    @IBOutlet weak var darkModeSwitch: UISwitch!
    @IBOutlet weak var darkModeLabel: UILabel!
    
    var bgView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        darkModeLabel.textColor = UIColor.white
        darkModeSwitch.isOn = UserDefaults.standard.bool(forKey: "isDarkMode")
        if (darkModeSwitch.isOn) {
            bgView = Styling.setUpBg(vc: self, imgName: "bg6")
            Styling.navDarkMode(vc: self)
        } else {
            bgView = Styling.setUpBg(vc: self, imgName: "bg5")
            Styling.navDayMode(vc: self)
        }
        Styling.styleFilledButton(signOutBtn, 0)
    }

    @IBAction func darkModePressed(_ sender: Any) {
        let name = Notification.Name("darkModeChanged")
        UserDefaults.standard.set(darkModeSwitch.isOn, forKey: "isDarkMode")
        NotificationCenter.default.post(name: name, object: nil)
        if (darkModeSwitch.isOn) {
            bgView.image = UIImage(named: "bg6")
            Styling.navDarkMode(vc: self)
        } else {
            bgView.image = UIImage(named: "bg5")
            Styling.navDayMode(vc: self)
        }
    }
}

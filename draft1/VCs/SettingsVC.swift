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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Styling.styleFilledButton(signOutBtn)
    }

    override func viewWillAppear(_ animated: Bool) {
        if (darkModeSwitch.isOn) {
            Styling.setBg(vc: self, imgName: "bg6")
        } else {
            Styling.setBg(vc: self, imgName: "bg5")
        }
    }

    @IBAction func darkModePressed(_ sender: Any) {
        let name = Notification.Name("darkModeChanged")
        UserDefaults.standard.set(darkModeSwitch.isOn, forKey: "isDarkMode")
        NotificationCenter.default.post(name: name, object: nil)
        if (darkModeSwitch.isOn) {
            Styling.setBg(vc: self, imgName: "bg6")
        } else {
            Styling.setBg(vc: self, imgName: "bg5")
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

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

    var bgView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        darkModeSwitch.isOn = UserDefaults.standard.bool(forKey: "isDarkMode")
        if (darkModeSwitch.isOn) {
            bgView = Styling.setUpBg(vc: self, imgName: "bg6")
        } else {
            bgView = Styling.setUpBg(vc: self, imgName: "bg5")
        }
        Styling.styleFilledButton(signOutBtn)
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//
//    }

    @IBAction func darkModePressed(_ sender: Any) {
        //let name = Notification.Name("darkModeChanged")
        UserDefaults.standard.set(darkModeSwitch.isOn, forKey: "isDarkMode")
        //UserDefaults.standard.synchronize()
//        NotificationCenter.default.post(name: name, object: nil)
        if (darkModeSwitch.isOn) {
            bgView.image = UIImage(named: "bg6")
        } else {
            bgView.image = UIImage(named: "bg5")
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

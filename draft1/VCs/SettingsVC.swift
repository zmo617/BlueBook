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
            navigationController?.navigationBar.barTintColor = UIColor(red: 0.2353, green: 0.5686, blue: 0.698, alpha: 1.0)
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            tabBarController?.tabBar.barTintColor = UIColor(red: 0.2353, green: 0.5686, blue: 0.698, alpha: 1.0)
        } else {
            bgView = Styling.setUpBg(vc: self, imgName: "bg5")
            navigationController?.navigationBar.barTintColor = UIColor.white
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
            tabBarController?.tabBar.barTintColor = UIColor.white
        }
        Styling.styleFilledButton(signOutBtn)
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//
//    }

    @IBAction func darkModePressed(_ sender: Any) {
        let name = Notification.Name("darkModeChanged")
        UserDefaults.standard.set(darkModeSwitch.isOn, forKey: "isDarkMode")
        NotificationCenter.default.post(name: name, object: nil)
        if (darkModeSwitch.isOn) {
            bgView.image = UIImage(named: "bg6")
            navigationController?.navigationBar.barTintColor = UIColor(red: 0.2353, green: 0.5686, blue: 0.698, alpha: 1.0)
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            tabBarController?.tabBar.barTintColor = UIColor(red: 0.2353, green: 0.5686, blue: 0.698, alpha: 1.0)
        } else {
            bgView.image = UIImage(named: "bg5")
            navigationController?.navigationBar.barTintColor = UIColor.white
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
            tabBarController?.tabBar.barTintColor = UIColor.white
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

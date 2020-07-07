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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Styling.setBg(vc: self, imgName: "bg6")
        Styling.styleFilledButton(signOutBtn)
            
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

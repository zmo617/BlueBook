//
//  AddGroupVC.swift
//  draft1
//
//  Created by Claire Mo on 6/14/20.
//  Copyright © 2020 Zongying Mo. All rights reserved.
//

import UIKit
import Firebase
class AddGroupVC: UIViewController {
   
    @IBOutlet weak var newTitleLabel: UILabel!
    @IBOutlet weak var newGroupTF: UITextField!
    @IBOutlet weak var createBtn: UIButton!
    
    //MARK:LOCAL PROPERTIES
    var mainVCDelegate: UIViewController!//homeVC
    let db = Firestore.firestore()
    var bgView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Styling.styleTextField(newGroupTF)
        Styling.styleFilledButton(createBtn, 0)
        if (UserDefaults.standard.bool(forKey: "isDarkMode")) {
            newTitleLabel.textColor = .white
            Styling.styleTextField(newGroupTF)
            Styling.styleFilledButton(createBtn, 20)
            bgView = Styling.setUpBg(vc: self, imgName: "bg6")
            Styling.navDarkMode(vc: self)
        } else {
            newTitleLabel.textColor = .black
            Styling.dayTextField(newGroupTF)
            Styling.dayFilledButton(createBtn, 20)
            bgView = Styling.setUpBg(vc: self, imgName: "bg5")
            Styling.navDayMode(vc: self)
        }
    }
    
    override func loadView() {
        super.loadView()
        setupView()
    }
    
    func setupView() {
        let name = Notification.Name("darkModeChanged")
        NotificationCenter.default.addObserver(self, selector: #selector(enableDarkMode), name: name, object: nil)
    }
    
    @objc func enableDarkMode() {
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        if (isDarkMode) {
            bgView.image = UIImage(named: "bg6")
        } else  {
            bgView.image = UIImage(named: "bg5")
        }
    }
    
    @IBAction func createPressed(_ sender: Any) {
        let mainVC = mainVCDelegate as! ViewController
        //create new object
        let newGroup = FavGroup(title: newGroupTF.text!)
        
        do {
            let docRef = self.db.collection("users").document(mainVC.userID)
            try docRef.collection("favGroups").document(self.newGroupTF.text!).setData(from: newGroup)
        } catch let error {
            print("Error adding Group to Firestore: \(error)")
        }
        //add it to objects
        mainVC.addGroup(newTitle: newGroupTF.text!)
        navigationController?.popViewController(animated: true)
    }
}

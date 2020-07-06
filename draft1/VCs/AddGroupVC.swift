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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Styling.setBg(vc: self, imgName: "bg6")
        Styling.styleTextField(newGroupTF)
        Styling.styleFilledButton(createBtn)
        // Do any additional setup after loading the view.
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

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
    
    //MARK:LOCAL PROPERTIES
    var mainVCDelegate: UIViewController!//homeVC
    let db = Firestore.firestore()
    var bgView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Styling.styleTextField(newGroupTF)
        bgView = Styling.setUpBg(vc: self, imgName: "bg6")
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
        performSegue(withIdentifier: "afterCreateGroup", sender: nil)
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

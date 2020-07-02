//
//  ShowObjectVC.swift
//  draft1
//
//  Created by Claire Mo on 6/14/20.
//  Copyright © 2020 Zongying Mo. All rights reserved.
//

import UIKit
import FirebaseUI
import FirebaseUI
import Firebase
import FirebaseFirestore
import FirebaseStorage
import FirebaseFirestoreSwift
class ShowObjectVC: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    //MARK:LOCAL PROPERTIES
    var selectedImage: String?
    var objectPath: [String]!
    var currentObject: FavObject!
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = currentObject.title
        let storageRef = Storage.storage().reference()
        let imgRef = storageRef.child(currentObject.coverImgPath)
        imageView.sd_setImage(with: imgRef)
        descriptionLabel.text = currentObject.content
        descriptionLabel.sizeToFit()
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEditObject",
            let addObjectVC = segue.destination as? AddObjectVC{//as? is casting
            addObjectVC.groupTableDelegate = self
            addObjectVC.editingObject = true
        }else if segue.identifier == "toContacts"{
            let contactsVC = segue.destination as? ContactsVC
            //email, group name, object name
            contactsVC?.sharingObject = objectPath
        }
    }
    
    func editObject(newCoverImgPath: String, newTitle: String, newContent: String){
        currentObject.title = newTitle
        currentObject.coverImgPath = newCoverImgPath
        currentObject.content = newContent
        
        
        // Delete the document before replacing it with the updated object
        db.collection("FavObjects").document("\(newTitle)").delete()
        
        do {
            try db.collection("FavObjects").document("\(newTitle)").setData(from: currentObject)
        } catch let error {
            print("Error writing city to Firestore: \(error)")
        }
        
    }

}

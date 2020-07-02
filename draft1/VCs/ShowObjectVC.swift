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
    var userID: String!
    var selectedGroup: String!
    
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
    
    func editObject(newCoverImgPath: String, newTitle: String, newContent: String){
        let docRef = self.db.collection("users").document(userID)
        docRef.collection("favGroups").document("\(self.selectedGroup!)").collection("favObjects").document("\(currentObject.title)").delete()
        
        currentObject.title = newTitle
        currentObject.coverImgPath = newCoverImgPath
        currentObject.content = newContent
        
        docRef.collection("favGroups").document("\(self.selectedGroup!)").collection("favObjects").document("\(currentObject.title)").setData(["content": currentObject.content, "coverImgPath": currentObject.coverImgPath, "title": currentObject.title], merge: true)
        
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEditObject",
            let addObjectVC = segue.destination as? AddObjectVC{//as? is casting
            addObjectVC.groupTableDelegate = self
            addObjectVC.editingObject = true
            addObjectVC.editingTitle = currentObject.title
            addObjectVC.editingContent = currentObject.content
            addObjectVC.editingImgPath = currentObject.coverImgPath
        }
    }

}

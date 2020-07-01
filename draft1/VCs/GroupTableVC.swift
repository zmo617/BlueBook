//
//  GroupTableVC.swift
//  draft1
//
//  Created by Claire Mo on 6/14/20.
//  Copyright © 2020 Zongying Mo. All rights reserved.
//

import UIKit
import FirebaseUI
import Firebase
import FirebaseFirestore
import FirebaseStorage
import FirebaseFirestoreSwift

class GroupTableVC: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var groupTable: UITableView!
    
    //MARK:LOCAL PROPERTIES
    var favObjects = [FavObject]()
    let db = Firestore.firestore()
    let storageRef = Storage.storage().reference()
    let showObjectSegueIdentifier = "toShowObject"
    var favObjRef: CollectionReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        favObjRef.getDocuments{(snapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                let tempObjects: [FavObject] = try! snapshot!.decoded()
                //self.favObjects = userObjects
                //print("will appear: obejcts.count = \(self.favObjects.count)")
                
                self.favObjects = tempObjects
                print("will appear: objects.count = \(self.favObjects.count)")
            }
        }
        groupTable.reloadData()
    }
    
    func addObject(newCoverImgPath: String, newTitle: String, newContent: String){
        //create new object
        let newObj = FavObject(title: newTitle,
                               coverImgPath: newCoverImgPath,
                               content: newContent)
        
        do {
            try db.collection("FavObjects").document("\(newTitle)").setData(from: newObj)
        } catch let error {
            print("Error writing city to Firestore: \(error)")
        }
        
        //add it to objects
        favObjects.append(newObj)
        //create new ObjectCell
    }
    
    //MARK: SETUP tableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favObjects.count
    }
    
    //indexPath: row index of cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "objectCell", for: indexPath as IndexPath) as! ObjectCell
        let curFavObject = favObjects[indexPath.item]
        //print("curFavObject name: \(curFavObject.title)")
        cell.setObjectCell(sourceObj: curFavObject)
        return cell
    }
    
    //swipe to delete object
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let obj = favObjects[indexPath.row]
            db.collection("FavObjects").document(obj.title).delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                }
            }
            let imgRef = storageRef.child(obj.coverImgPath)
            imgRef.delete{ error in
              if let error = error {
                print("Error deleting img from Firebase Storage(): \(error)")
              } else {
                 print("img deleted from Firebase Storage().")
              }
            }
            favObjects.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .bottom)
        }
    }
    
    //MARK: Segues, set delegates
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAddObject",
            let addObjectVC = segue.destination as? AddObjectVC{//as? is casting
            addObjectVC.groupTableDelegate = self
        } else if segue.identifier == showObjectSegueIdentifier,
            let showObjectVC = segue.destination as? ShowObjectVC,
            let objectIndex = groupTable.indexPathForSelectedRow?.row {
            showObjectVC.currentObject = favObjects[objectIndex]
            
        }
    }
    
    
}

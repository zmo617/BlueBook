//
//  ViewController.swift
//  draft1
//
//  Created by Claire Mo on 6/14/20.
//  Copyright © 2020 Zongying Mo. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift
import FirebaseFirestore

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, DataCollectionProtocol {
    
    //***temp delete group
    func deleteData(index: Int) {
        groups.remove(at: index)
        groupsBook.reloadData()
    }
    
    //***temp delete group
    enum Mode {
        case view
        case select
    }
    
    @IBOutlet weak var groupsBook: UICollectionView!
    @IBOutlet weak var welcomeLabel: UILabel!
    
    
    //MARK:LOCAL PROPERTIES
    var groups = [FavGroup]()
    let db = Firestore.firestore()
    let storageRef = Storage.storage().reference()
    var curUser: User!
    
    override func viewDidAppear(_ animated: Bool) {
        welcomeLabel.text = "\(curUser.firstname)'s Favorites"
       
        let docRef = db.collection("users").document(curUser.email).collection("favGroups")
        docRef.getDocuments{(snapshot, error) in
            let tempGroups: [FavGroup] = try! snapshot!.decoded()
            self.groups = tempGroups
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        groupsBook.reloadData()
    }
    
    //MARK: SETUP collection view "groupsBook" ------------
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return groups.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "groupCell", for: indexPath as IndexPath) as! CollectionViewCell
        cell.groupButton.setTitle(groups[indexPath.row].title, for: .normal)
        cell.index = indexPath//***temp delete group
        cell.delegate = self//***temp delete group
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.row)
    }
    
    func addGroup(newTitle: String){
        groups.append(FavGroup(title: "newTitle"))
    }
    
    //MARK: Segues, set delegates
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAddGroup",
            let addGroupVC = segue.destination as? AddGroupVC{//as? is casting
            addGroupVC.mainVCDelegate = self
        }else if segue.identifier == "toGroupTable"{
                let groupVC = segue.destination as! GroupTableVC
            let docRef = groupVC.db.collection("FavObjects")
            docRef.getDocuments{(snapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                } else {
                    let userObjects: [FavObject] = try! snapshot!.decoded()
                    //self.favObjects = userObjects
                    //print("will appear: obejcts.count = \(self.favObjects.count)")
//                    for document in snapshot!.documents {
//                        let obj = try! document.data(as: FavObject.self)
//                        userObjects.append(obj!)
//                    }
                    groupVC.favObjects = userObjects
                    print("will appear: objects.count = \(groupVC.favObjects.count)")
                }
            }
        }
        
    }
}


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
    var userID: String!
    var groupsRef: CollectionReference!
    var selectedGroup: String!
    //var loginDelegate: UIViewController!
    
    override func viewDidAppear(_ animated: Bool) {
        let queue = DispatchQueue(label: "dispatchQ")
        print("userID:\(userID)")
        //setting up curUser
        queue.sync {
            let docRef = self.db.collection("users").document(userID)
            docRef.getDocument{(snapshot, error) in
                if error != nil{
                    print(error?.localizedDescription ?? "Error in getting user from firebase")
                }else{
                    //let tempUser = try! snapshot!.data(as: User.self)
                    let tempUser = try! snapshot!.data(as: User.self)
                    //self.curUser = tempUser
                    self.welcomeLabel.text = "\(tempUser!.firstname)'s Favorites"
                    self.groupsRef = self.db.collection("users").document(tempUser!.email).collection("favGroups")
                    self.groupsRef.getDocuments{(snapshot, error) in
                        let tempGroups: [FavGroup] = try! snapshot!.decoded()
                        self.groups = tempGroups
                    }
                    self.curUser = tempUser
                }
            }
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
        cell.groupButton.addTarget(self, action: #selector(self.groupTapped), for: .touchUpInside)
        cell.index = indexPath//***temp delete group
        cell.delegate = self//***temp delete group
        return cell
    }
    
    @objc func groupTapped(sender: UIButton){
        selectedGroup = sender.currentTitle
        performSegue(withIdentifier: "toGroupTable", sender: nil)
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
        
            //what's in groupTable is the objects in this group
            let groupVC = segue.destination as! GroupTableVC
            groupVC.objectPath = [userID, selectedGroup]
            groupVC.selectedGroup = self.selectedGroup
            //            groupVC.groupRef.getDocuments{(snapshot, error) in
//                if let error = error {
//                    print("Error getting documents: \(error)")
//                } else {
//                    let userObjects: [FavObject] = try! snapshot!.decoded()
//                    //self.favObjects = userObjects
//                    //print("will appear: obejcts.count = \(self.favObjects.count)")
//                    //                    for document in snapshot!.documents {
//                    //                        let obj = try! document.data(as: FavObject.self)
//                    //                        userObjects.append(obj!)
//                    //                    }
//                    groupVC.favObjects = userObjects
//                    print("will appear: objects.count = \(groupVC.favObjects.count)")
//                }
//            }
        }
        
    }
}


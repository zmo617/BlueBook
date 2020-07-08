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
    @IBOutlet weak var addBtn: UIButton!
    
    
    //MARK:LOCAL PROPERTIES
    var favObjects = [FavObject]()
    let db = Firestore.firestore()
    let storageRef = Storage.storage().reference()
    let showObjectSegueIdentifier = "toShowObject"
    var selectedGroup: String!
    var objectPath: [String]!
    var bgView: UIImageView!
    var userID: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        groupTable.backgroundView = nil
        groupTable.backgroundColor = .clear
        bgView = Styling.setUpBg(vc: self, imgName: "bg6")
        Styling.styleFilledRoundButton(addBtn)
        self.title = selectedGroup
        // Trying to set up dark mode
        // setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("\n objectPath[0] should be userID: \(objectPath[0]), objectPath[1] should be selectedGroup: \(objectPath[1])")
        
        let ref = db.collection("users").document(objectPath[0]).collection("favGroups").document(selectedGroup)
        if selectedGroup == "sharedObjects"{
            //get shared object paths
            let objectsRef = ref.collection("objectPaths")
            objectsRef.getDocuments{(snapshot, error) in
                //use the paths to get each sharedObject
                if error == nil{
                    let docs = snapshot?.documents
                    //and add each object to sharedObjects group, i.e. the favObjects list
                    docs?.forEach{doc in
                        let docData = doc.get("path") as! [String]
                        let objRef = self.db.collection("users").document(docData[0]).collection("favGroups").document(docData[1]).collection("favObjects").document(docData[2])
                        objRef.getDocument{(document, error) in
                            if error != nil{
                                print(error?.localizedDescription ?? "Error loading sharedObject to reader")
                            }else{
                                let tempObj = try! document!.data(as: FavObject.self)
                                self.favObjects.append(tempObj!)
                            }
                        }
                    }
                    self.groupTable.reloadData()
                }else{
                    print("\n Error fetching sharedObjects: \(error!.localizedDescription)\n")
                }
            }
        }else{
//            DispatchQueue.global(qos: .userInteractive).async{
//                let downloadGroup = DispatchGroup()
                let groupRef = ref.collection("favObjects")
//                downloadGroup.enter()
                groupRef.getDocuments{(snapshot, error) in
                    if let error = error {
                        print("Error getting documents: \(error)")
                    } else {
                        let tempObjects: [FavObject] = try! snapshot!.decoded()
                        //self.favObjects = userObjects
                        //print("will appear: obejcts.count = \(self.favObjects.count)")
                        self.favObjects = tempObjects
                        self.groupTable.reloadData()
//                        downloadGroup.leave()
                    }
                }
//                downloadGroup.wait()
//            }
           
            print("will appear: objects.count = \(self.favObjects.count)")
        }
    }
    
    // Attemping dark mode
    /*
    func setupView() {
        let name = Notification.Name("darkModeChanged")
        NotificationCenter.default.addObserver(self, selector: #selector(enableDarkMode), name: name, object: nil)
    }
    
    @objc func enableDarkMode() {
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        if (isDarkMode) {
            Styling.setBg(vc: self, imgName: "bg6")
        } else  {
            Styling.setBg(vc: self, imgName: "bg5")
        }
    }
    */
    func addObject(newCoverImgPath: String, newTitle: String, newContent: String){
        //create new object
        let newObj = FavObject(title: newTitle,
                               coverImgPath: newCoverImgPath,
                               content: newContent)
        
        do {
            let docRef = self.db.collection("users").document(userID)
            try docRef.collection("favGroups").document("\(self.selectedGroup!)").collection("favObjects").document("\(newObj.title)").setData(from: newObj)
            
        } catch let error {
            print("Error writing to Firestore: \(error)")
        }
        
        //add it to objects
        favObjects.append(newObj)
        //create new ObjectCell
        
        //print("objects.count: \(favObjects.count)")
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
        DispatchQueue.main.async{
             cell.setObjectCell(sourceObj: curFavObject)
        }

        cell.backgroundView = nil
        cell.backgroundColor = .clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        objectPath.append(favObjects[indexPath.row].title)
    }
    
    //swipe to delete object
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let obj = favObjects[indexPath.row]
            let userRef = self.db.collection("users").document(userID)
            userRef.collection("favGroups").document("\(self.selectedGroup!)").collection("favObjects").document(obj.title).delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                }
            }
            let imgsRef = self.storageRef.child("/images/\(objectPath[0])/\(objectPath[1])/\(obj.title)")
            imgsRef.delete{ error in
              if let error = error {
                print("Error deleting imgs from Firebase Storage(): \(error)")
              } else {
                 print("imgs deleted from Firebase Storage().")
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
            addObjectVC.editingObject = false
            addObjectVC.objectPath = objectPath
        } else if segue.identifier == showObjectSegueIdentifier,
            let showObjectVC = segue.destination as? ShowObjectVC,
            let objectIndex = groupTable.indexPathForSelectedRow?.row {
            showObjectVC.currentObject = favObjects[objectIndex]
            showObjectVC.userID = userID
            //add objectID, now it's userID, group name, objectID
            self.objectPath.append(favObjects[objectIndex].title)
            showObjectVC.objectPath = self.objectPath
        }
    }
    
}

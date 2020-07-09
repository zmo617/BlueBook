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
    var sharedPaths: [[String]]!
    var bgView: UIImageView!
    var userID: String!
    var isShared: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        groupTable.backgroundView = nil
        groupTable.backgroundColor = .clear
        Styling.styleFilledRoundButton(addBtn)
        self.title = selectedGroup
        if (UserDefaults.standard.bool(forKey: "isDarkMode")) {
            bgView = Styling.setUpBg(vc: self, imgName: "bg6")
            navigationController?.navigationBar.barTintColor = UIColor(red: 0.2353, green: 0.5686, blue: 0.698, alpha: 1.0)
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            tabBarController?.tabBar.barTintColor = UIColor(red: 0.2353, green: 0.5686, blue: 0.698, alpha: 1.0)
        } else {
            bgView = Styling.setUpBg(vc: self, imgName: "bg5")
            navigationController?.navigationBar.barTintColor = UIColor.white
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
            tabBarController?.tabBar.barTintColor = UIColor.white
        }
        
        print("\n objectPath[userID, selectedGroup]: \(objectPath)\n")
        
        let ref = db.collection("users").document(objectPath[0]).collection("favGroups").document(selectedGroup)
        if selectedGroup == "sharedObjects"{
            isShared = true
            let placeHolderFavObj = FavObject(title: "", coverImgPath: "", content: "")
            DispatchQueue.main.async {
                //get shared object paths
                let objectsRef = ref.collection("objectPaths")
                objectsRef.getDocuments{(snapshot, error) in
                    //use the paths to get each sharedObject
                    if error == nil{
                        let docs = snapshot?.documents
                        let docsCount = docs!.count
                        self.sharedPaths = [[String]](repeating: [], count: docsCount)
                        self.favObjects = [FavObject](repeating: placeHolderFavObj, count: docsCount)
                        //and add each object to sharedObjects group, i.e. the favObjects list
                        for i in 0 ..< docsCount{
                            
                            let docData = docs![i].get("path") as! [String]
                            print("\n docs[\(i)]: \(docData) \n")
                            
                            self.sharedPaths[i] = docData
                            let objRef = self.db.collection("users").document(docData[0]).collection("favGroups").document(docData[1]).collection("favObjects").document(docData[2])
                            print("\n document: \(docData[1]),\(docData[2])")
                            objRef.getDocument{(document, error) in
                                if error != nil{
                                    print(error?.localizedDescription ?? "Error loading sharedObject to reader")
                                }else{
                                    let tempObj = try! document!.data(as: FavObject.self)
                                    if tempObj == nil{
                                        let controller = UIAlertController(title: "Error", message: "The author has changed/deleted this post", preferredStyle: .alert)
                                        
                                            controller.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                        
                                        self.present(controller, animated: true, completion: nil)
                                    }else{
                                        self.favObjects[i] = tempObj!
                                        self.groupTable.reloadData()
                                    }
                                    
                                }
                            }
                        }
                    }else{
                        print("\n Error fetching sharedObjects: \(error!.localizedDescription)\n")
                    }
                }
            }
            
        }else{
            isShared = false
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
    
    //    override func loadView() {
    //        super.loadView()
    //
    //    }
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        groupTable.reloadData()
    }
    
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
        
        cell.titleLabel.text = curFavObject.title
        DispatchQueue.main.async {
            let imgRef = self.storageRef.child(curFavObject.coverImgPath)
            cell.coverImgView.sd_setImage(with: imgRef)
            print("curFavObject name: \(curFavObject.title)")
        }
        
        
        
        cell.titleLabel.textColor = UIColor.white
        cell.backgroundView = nil
        cell.backgroundColor = .clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isShared{
            objectPath = sharedPaths[indexPath.row]
        }else{
            
            if(objectPath.count < 3){
                objectPath.append(favObjects[indexPath.row].title)
            }else{
                objectPath[2] = favObjects[indexPath.row].title
            }
        }
        print("\n <shared> Selected obj : \(objectPath)\n")
        performSegue(withIdentifier: "toShowObject", sender: nil)
    }
    
    //swipe to delete object
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if !isShared{if editingStyle == .delete{
            let obj = favObjects[indexPath.row]
            let userRef = self.db.collection("users").document(userID)
            //                if isShared{
            //                    print("userID: \(userID!), objTitle: \(obj.title)")
            //                    userRef.collection("favGroups").document(self.selectedGroup!).collection("objectPaths").document(obj.title).delete(){err in
            //                        if let err = err {
            //                            print("Error removing document: \(err)")
            //                        } else {
            //                            print("Document successfully removed!")
            //                        }
            //                    }
            //                }else{
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
            //}
            favObjects.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .bottom)
            }}
        
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
            showObjectVC.objectPath = self.objectPath
        }
    }
    
}

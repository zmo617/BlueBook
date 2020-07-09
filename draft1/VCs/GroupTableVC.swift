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
    var favObjects = [FavObject]()//data source for table view
    let db = Firestore.firestore()
    let storageRef = Storage.storage().reference()
    let showObjectSegueIdentifier = "toShowObject"
    var selectedGroup: String! //parent group
    var objectPath: [String]! //will be altered to pass to nextVC
    var sharedPaths: [[String]]!//if parent group is "sharedObjects"
    var bgView: UIImageView!
    var userID: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //styling
        groupTable.backgroundView = nil
        groupTable.backgroundColor = .clear
        Styling.styleFilledRoundButton(addBtn)
        self.title = selectedGroup
        if (UserDefaults.standard.bool(forKey: "isDarkMode")) {
            bgView = Styling.setUpBg(vc: self, imgName: "bg6")
            Styling.navDarkMode(vc: self)
        } else {
            bgView = Styling.setUpBg(vc: self, imgName: "bg5")
            Styling.navDayMode(vc: self)
        }
        UserDefaults.standard.set(selectedGroup == "sharedObjects", forKey: "isShared")
        
        //load data
        let ref = db.collection("users").document(objectPath[0]).collection("favGroups").document(selectedGroup)
        if UserDefaults.standard.bool(forKey: "isShared"){
            //shared:
            let placeHolderFavObj = FavObject(title: "", coverImgPath: "", content: "")
            DispatchQueue.main.async {
                //get shared object paths
                let objectsRef = ref.collection("objectPaths")
                objectsRef.getDocuments{(snapshot, error) in
                    //use the paths to get each sharedObject
                    if error == nil{
                        let docs = snapshot?.documents
                        let docsCount = docs!.count
                        //var tempPaths = [[String]]()
                        self.sharedPaths = [[String]](repeating: [], count: docsCount)//
                        self.favObjects = [FavObject](repeating: placeHolderFavObj, count: docsCount)
                        
                        //and add each object to sharedObjects group, i.e. the favObjects list
                        var j = 0
                        for i in 0 ..< docsCount{
                            
                            let docData = docs![i].get("path") as! [String]
                            let objRef = self.db.collection("users").document(docData[0]).collection("favGroups").document(docData[1]).collection("favObjects").document(docData[2])
                            
                            objRef.getDocument{(document, error) in
                                if error != nil{
                                    print(error?.localizedDescription ?? "Error loading sharedObject to reader")
                                }else{
                                    let tempObj = try! document!.data(as: FavObject.self)
                                    if tempObj == nil{
                                        Styling.errorAlert(vc: self, msg: "The author has changed/deleted post: \(docData[2])")
                                        ref.collection("objectPaths").document(docData[2]).delete{(error) in
                                            if error != nil{
                                                Styling.errorAlert(vc: self, msg: "Error removing \(docData[2]) from sharedObjects")
                                            }else{
                                                self.sharedPaths.remove(at: self.sharedPaths.count - 1)
                                                self.favObjects.remove(at: self.favObjects.count - 1)
                                            }
                                        }
                                    }else{
                                        //current object valid
                                        self.sharedPaths[j] = docData
                                        self.favObjects[j] = tempObj!
                                        self.groupTable.reloadData()
                                        j += 1
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
            //regular group
            let groupRef = ref.collection("favObjects")
            groupRef.getDocuments{(snapshot, error) in
                if let error = error {
                    Styling.errorAlert(vc: self, msg: "Error getting documents: \(error)")
                } else {
                    let tempObjects: [FavObject] = try! snapshot!.decoded()
                    self.favObjects = tempObjects
                    self.groupTable.reloadData()
                }
            }
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
            Styling.errorAlert(vc: self, msg: "Error writing to Firestore: \(error)")
        }
        
        //add it to objects
        favObjects.append(newObj)
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
        }
        cell.coverImgView.layer.borderColor = UIColor.white.cgColor
        cell.titleLabel.textColor = UIColor.white
        cell.backgroundView = nil
        cell.backgroundColor = .clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if UserDefaults.standard.bool(forKey: "isShared"){
            objectPath = sharedPaths[indexPath.row]
        }else{
            //haven't gone to showObjectVC, append object to show in path
            if(objectPath.count < 3){
                objectPath.append(favObjects[indexPath.row].title)
            }else{
            //has been to showObjectVC, reset object to show
                objectPath[2] = favObjects[indexPath.row].title
            }
        }
        performSegue(withIdentifier: "toShowObject", sender: nil)
    }
    
    //swipe to delete object
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        //if shared, can swipe but delete would be disabled
        if !UserDefaults.standard.bool(forKey: "isShared"){
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

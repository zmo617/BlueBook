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
    
    //delete group
    func deleteData(index: Int) {
        let groupName = groups[index].title
        self.db.collection("users").document(userID).collection("favGroups").document(groupName).delete()
        groups.remove(at: index)
        groupsBook.reloadData()
    }
    
    //delete group
    enum Mode {
        case view
        case select
    }
    
    @IBOutlet weak var groupsBook: UICollectionView!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var settingsBtn: UIButton!
    
    //MARK:LOCAL PROPERTIES
    var groups = [FavGroup]()//groupsBook datasource
    let db = Firestore.firestore()//Firestore database
    let storageRef = Storage.storage().reference()//Firestore storage
    var curUser: User!//use userID to get user info from db
    var userID: String!//email
    var groupsRef: CollectionReference!//ref groups in the collection of "favGroup"
    var selectedGroup: String!
    var editMode = false//switch to editMode to delete groups
    var bgView: UIImageView!//background view
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let currentUser = Auth.auth().currentUser
        userID = currentUser!.email
        
        //Styling
        Styling.styleHollowButton(settingsBtn, 15)
        if (UserDefaults.standard.bool(forKey: "isDarkMode")) {
            //Styling.styleHollowButton(editBtn, 15)
            bgView = Styling.setUpBg(vc: self, imgName: "bg6")
            Styling.navDarkMode(vc: self)
        } else {
            //Styling.dayHollowButton(editBtn, 15)
            bgView = Styling.setUpBg(vc: self, imgName: "bg5")
            Styling.navDayMode(vc: self)
        }
        groupsBook.backgroundView = nil
        groupsBook.backgroundColor = .clear
        Styling.styleFilledRoundButton(addBtn)
        
        //get groups
        let docRef = self.db.collection("users").document(userID)
        docRef.getDocument{(snapshot, error) in
            if error != nil{
                Styling.errorAlert(vc: self, msg: error?.localizedDescription ?? "Error in getting user from firebase")
            }else{
                //success
                do{
                    //get user info
                    let tempUser = try snapshot!.data(as: User.self)
                    self.welcomeLabel.text = "\(tempUser!.firstname)'s BlueBook"
                    self.groupsRef = self.db.collection("users").document(tempUser!.email).collection("favGroups")
                    self.groupsRef.getDocuments{(snapshot, error) in
                        let tempGroups: [FavGroup] = try! snapshot!.decoded()
                        self.groups = tempGroups
                        self.groupsBook.reloadData()
                    }
                    self.curUser = tempUser
                }catch{
                    Styling.errorAlert(vc: self, msg: "Inconsistency in Firebase User structure.")
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
        cell.index = indexPath//delete group
        cell.delegate = self//delete group
        if (editMode) {
            cell.deleteBtn.isHidden = false
            cell.deleteView.isHidden = false
        } else {
            cell.deleteBtn.isHidden = true
            cell.deleteView.isHidden = true
        }
        Styling.styleHollowButton(cell.groupButton, 17)
        return cell
    }
    
    @objc func groupTapped(sender: UIButton){
        selectedGroup = sender.currentTitle
        performSegue(withIdentifier: "toGroupTable", sender: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
    
    func addGroup(newTitle: String){
        groups.append(FavGroup(title: newTitle))
    }
    
    //switch to edit mode
    @IBAction func editPressed(_ sender: Any) {
        if (!editMode) {
            editMode = true
            editBtn.setTitle("Done", for: .normal)
            groupsBook.reloadData()
        } else {
            editMode = false
            editBtn.setTitle("Edit", for: .normal)
            groupsBook.reloadData()
        }
    }
    
    //MARK: Segues, set delegates
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAddGroup",
            let addGroupVC = segue.destination as? AddGroupVC{
            addGroupVC.mainVCDelegate = self
            
        }else if segue.identifier == "toGroupTable"{
            let groupVC = segue.destination as! GroupTableVC
            groupVC.userID = userID
            groupVC.selectedGroup = self.selectedGroup
            groupVC.objectPath = [userID, selectedGroup]
        }
    }
}


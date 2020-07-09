//
//  ContactsVC.swift
//  draft1
//
//  Created by Kevin Diep on 6/16/20.
//  Copyright © 2020 Zongying Mo. All rights reserved.
//

import UIKit
import Firebase

class ContactsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var contactsTable: UITableView!
    @IBOutlet weak var doneBtn: UIButton!
    
    let db = Firestore.firestore()
    var userList = [User]()
    var selectedUsers = [User]()
    var sharingObject: [String]!
    var bgView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (UserDefaults.standard.bool(forKey: "isDarkMode")) {
            Styling.styleHollowButton(doneBtn, 15)
            bgView = Styling.setUpBg(vc: self, imgName: "bg6")
            Styling.navDarkMode(vc: self)
        } else {
            Styling.dayHollowButton(doneBtn, 15)
            bgView = Styling.setUpBg(vc: self, imgName: "bg5")
            Styling.navDayMode(vc: self)
        }
        contactsTable.delegate = self
        contactsTable.dataSource = self
        contactsTable.backgroundView = nil
        contactsTable.backgroundColor = .clear
        contactsTable.allowsMultipleSelection = true
        let usersRef = db.collection("users")
        usersRef.getDocuments{(snapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                let tempUsers: [User] = try! snapshot!.decoded()
                //excluding current user
                self.userList = tempUsers
                let userIndex = self.userList.firstIndex(where: {$0.email == self.sharingObject[0]})
                self.userList.remove(at: userIndex!)
                self.contactsTable.reloadData()
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
        contactsTable.reloadData()
    }
    
    @IBAction func doneTapped(_ sender: Any) {
        let controller = UIAlertController(title: "Share", message: "Share this post with \(contactsTable.indexPathsForSelectedRows!.count) people", preferredStyle: .alert)
        
        controller.addAction(UIAlertAction(title: "OK", style: .default, handler: {
            (action: UIAlertAction!) in
            let indexPaths = self.contactsTable.indexPathsForSelectedRows
            //adding sharingObject to each user's "sharedObjects" collection
            for indexPath in indexPaths!{
                
                let thisUser = self.userList[indexPath.row]//****
                let groupsRef = self.db.collection("users").document(thisUser.email).collection("favGroups").document("sharedObjects")
                groupsRef.collection("objectPaths").document(self.sharingObject[2]).setData(["path": self.sharingObject!]){(error) in
                    if error != nil{
                        print("\n Error adding sharedObject to firebase: \(error as Any)")
                    }
                }
            }
        }))
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(controller, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = contactsTable.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath) as! ContactCell
        let user = userList[indexPath.row]
        let selectedIndexPaths = tableView.indexPathsForSelectedRows
        let rowIsSelected = selectedIndexPaths != nil && selectedIndexPaths!.contains(indexPath)
        cell.accessoryType = rowIsSelected ? .checkmark : .none
        cell.nameLabel.text = "\(user.firstname) \(user.lastname)"
        cell.nameLabel.textColor = UIColor.white
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        if (isDarkMode) {
            cell.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.0)
        } else  {
            cell.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.0)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        cell.accessoryType = .checkmark
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        cell.accessoryType = .none
    }
}

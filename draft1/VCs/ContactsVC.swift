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
    
    let db = Firestore.firestore()
    var userList = [User]()
    var selectedUsers = [User]()
    var sharingObject: [String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contactsTable.delegate = self
        contactsTable.dataSource = self
        
        contactsTable.allowsMultipleSelection = true
        let usersRef = db.collection("users")
        usersRef.getDocuments{(snapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                let tempUsers: [User] = try! snapshot!.decoded()
                //self.favObjects = userObjects
                //print("will appear: obejcts.count = \(self.favObjects.count)")
                //excluding current user
                self.userList = tempUsers
                let userIndex = self.userList.firstIndex(where: {$0.email == self.sharingObject[0]})
                self.userList.remove(at: userIndex!)
                self.contactsTable.reloadData()
            }
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        contactsTable.reloadData()
    }
    
    @IBAction func doneTapped(_ sender: Any) {
        print("userList.count = \(userList.count)")
        let indexPaths = contactsTable.indexPathsForSelectedRows
        for indexP in indexPaths!{
            print(indexP.row)
        }
        //adding sharingObject to each user's "sharedObjects" collection
        for indexPath in indexPaths!{
            
            let thisUser = userList[indexPath.row]//****
            let groupsRef = db.collection("users").document(thisUser.email).collection("favGroups").document("sharedObjects")
            groupsRef.collection("objectPaths").document(sharingObject[2]).setData(["path": sharingObject]){(error) in
                if error != nil{
                    print("\n Error adding sharedObject to firebase: \(error as Any)")
                }
            }
            print("\n\n sharingObject:", sharingObject ?? "nil")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = contactsTable.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath) as! ContactCell
        let user = userList[indexPath.row]
        print(user.firstname)
        let selectedIndexPaths = tableView.indexPathsForSelectedRows
        let rowIsSelected = selectedIndexPaths != nil && selectedIndexPaths!.contains(indexPath)
        cell.accessoryType = rowIsSelected ? .checkmark : .none
        cell.nameLabel.text = "\(user.firstname) \(user.lastname)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        cell.accessoryType = .checkmark
        // cell.accessoryView.hidden = false // if using a custom image
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        cell.accessoryType = .none
        // cell.accessoryView.hidden = true  // if using a custom image
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    
}

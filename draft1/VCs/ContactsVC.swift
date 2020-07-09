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
        Styling.styleFilledButton(doneBtn)
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

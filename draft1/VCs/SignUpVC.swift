//
//  SignUpVC.swift
//  draft1
//
//  Created by Claire Mo on 6/23/20.
//  Copyright © 2020 Zongying Mo. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
class SignUpVC: UIViewController {
    
    @IBOutlet weak var firstNameTF: UITextField!
    @IBOutlet weak var lastNameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var pwTF: UITextField!
    @IBOutlet weak var confirmPwTF: UITextField!
    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    var cEmail: String!
    var bgView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorLabel.alpha = 0
        if (UserDefaults.standard.bool(forKey: "isDarkMode")) {
            bgView = Styling.setUpBg(vc: self, imgName: "bg6")
            Styling.styleTextField(emailTF)
            Styling.styleTextField(firstNameTF)
            Styling.styleTextField(lastNameTF)
            Styling.styleTextField(pwTF)
            Styling.styleTextField(confirmPwTF)
            Styling.styleHollowButton(signUpBtn, 20)
        }else{
            bgView = Styling.setUpBg(vc: self, imgName: "bg5")
            Styling.dayTextField(emailTF)
            Styling.dayTextField(firstNameTF)
            Styling.dayTextField(lastNameTF)
            Styling.dayTextField(pwTF)
            Styling.dayTextField(confirmPwTF)
            Styling.dayHollowButton(signUpBtn, 20)
        }
        
    }
    
    //if there's an error, return error msg
    //o.w. return nil
    //only checking if all fields are filled in, not checking pw security level
    func validateFields() -> String? {
        if emailTF.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            pwTF.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            firstNameTF.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            lastNameTF.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            return "Please fill in all fields."
        }
        return nil
    }
    
    func showError(errMsg: String){
        errorLabel.text = errMsg
        errorLabel.alpha = 1
    }
    
    func goToHomeVC(){
        let homeVC = storyboard?.instantiateViewController(identifier: "homeVC") as? ViewController
        view.window?.rootViewController = homeVC
        view.window?.makeKeyAndVisible()
    }
    
    @IBAction func createUserTapped(_ sender: Any) {
        let error = validateFields();
        if error == nil{
            //get clean versions of the new user info
            let cFirstName = firstNameTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let cLastName = lastNameTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            cEmail = emailTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let cPw = pwTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            //create user: auth() returns the new uid in rst and error(if any) in err
            Auth.auth().createUser(withEmail: cEmail, password: cPw) {(rst, err) in
                if err == nil{
                    //no errors creating the user
                    let db = Firestore.firestore()
                    let newUser = User(email: self.cEmail,
                                       firstname: cFirstName,
                                       lastname: cLastName,
                                       password: cPw)
                    do {
                        try db.collection("users").document("\(self.cEmail!)").setData(from: newUser)
                    } catch let error {
                        self.showError(errMsg: "Error saving user data.")
                        print("Error writing newUser to Firestore: \(error)")
                    }
                    //create default favGroups -> default doc "sharedObject"
                    db.collection("users").document("\(self.cEmail!)").collection("favGroups").document("sharedObjects").setData(["title": "sharedObjects"]){(error) in
                        if error != nil{
                            self.showError(errMsg: "Error creating default sharedObjects: \(error)")
                        }
                    }
                    //go to mainVC "ViewController"
                    self.performSegue(withIdentifier: "toHome", sender: nil)
                }else{
                    self.showError(errMsg: error ?? "")
                    
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toHome"{
            let homeVC = segue.destination as! ViewController
            homeVC.userID = self.cEmail
        }
    }
}

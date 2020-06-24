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

class SignUpVC: UIViewController {

    @IBOutlet weak var firstNameTF: UITextField!
    @IBOutlet weak var lastNameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var pwTF: UITextField!
    @IBOutlet weak var confirmPwTF: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorLabel.alpha = 0
        // Do any additional setup after loading the view.
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
            let cEmail = emailTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let cPw = pwTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            //create user: auth() returns the new uid in rst and error(if any) in err
            Auth.auth().createUser(withEmail: cEmail, password: cPw, completion: {(rst, err) in
                if err == nil{
                    //no errors creating the user
                    let db = Firestore.firestore()
                    db.collection("users").addDocument(data: [
                        "firstname": cFirstName,
                        "lastname": cLastName,
                        "email": cEmail,
                        "password": cPw,
                        "uid": rst!.user.uid
                    ]){(error) in
                        //error updating/storing data into database
                        if error != nil{
                            self.showError(errMsg: "Error saving user data.")
                        }}
                    //go to mainVC "ViewController"
                    self.goToHomeVC()
                    //***Auth.auth().signIn(withEmail: self.emailTF.text!, password: self.pwTF.text!)
                }else{
                    //error creating the user
                    self.showError(errMsg: "Error creating new user.")
                }
            })
        }else{
            showError(errMsg: error!)
        }
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

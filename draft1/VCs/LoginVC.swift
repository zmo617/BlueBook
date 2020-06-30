//
//  LoginVC.swift
//  draft1
//
//  Created by Claire Mo on 6/23/20.
//  Copyright © 2020 Zongying Mo. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
class LoginVC: UIViewController {
    
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var pwTF: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    let db = Firestore.firestore()
    let storageRef = Storage.storage().reference()
    var cEmail: String!
    var cPw: String!
    var curUser: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorLabel.alpha = 0
        // Do any additional setup after loading the view.
    }
    
    //if there's an error, return error msg
    //o.w. return nil
    //only checking if both fields are filled in, not checking pw security level
    func validateFields() -> String? {
        if emailTF.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            pwTF.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            return "Please fill in both email and password."
        }
        
        return nil
    }
    
    func showError(errMsg: String){
        errorLabel.text = errMsg
        errorLabel.alpha = 1
    }
    
    //    func goToHomeVC(){
    //        let homeVC = storyboard?.instantiateViewController(identifier: "homeVC") as? ViewController
    //        view.window?.rootViewController = homeVC
    //        view.window?.makeKeyAndVisible()
    //    }
    
    @IBAction func loginBtnPressed(_ sender: Any) {
        let error = validateFields();
        let queue = DispatchQueue(label: "dispatchQ")
        
        queue.sync {
            if error == nil{
                //get clean versions of the login info
                cEmail = emailTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                cPw = pwTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                Auth.auth().signIn(withEmail: self.cEmail, password: self.cPw, completion: {(rst, err) in
                    if err == nil{
                        //set curUser
                        let docRef = self.db.collection("users").document("123456@utexas.edu")
                        print("\n\n docRef = \(docRef == nil), \(docRef.documentID)")
                        docRef.getDocument{(snapshot, error) in
                            print("\n\n snapshot nil ? \(snapshot == nil), \(snapshot?.data())")
                            if error != nil{
                                print("\n\n")
                                print(error?.localizedDescription ?? "Error in getting user from firebase")
                                print("\n\n")
                            }else{
                                //let tempUser = try! snapshot!.data(as: User.self)
                                let tempUser = try! snapshot!.data(as: User.self)
                                print("\n\n tempUser nil ? \(tempUser == nil), \(tempUser?.firstname ?? "nil no email")")
                                self.curUser = tempUser
                            }
                        }
                    }else{
                        self.showError(errMsg: "\(err?.localizedDescription ?? "Error signing in.")")
                    }
                })
            }else{
                self.showError(errMsg: error!)
            }
            
        }
        
        // does not wait. But the code in notify() gets run
        // after enter() and leave() calls are balanced
        
        performSegue(withIdentifier: "toHomeVC", sender: nil)
    }
    
    //    func signIn(){
    //
    //    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toHomeVC"{
            let homeVC = segue.destination as! ViewController
            homeVC.curUser = self.curUser
            print("\n\n curUser name: \(self.curUser?.firstname ?? "")")
        }
    }
    
    
}

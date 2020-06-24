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

class LoginVC: UIViewController {

    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var pwTF: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    var userUid: String!
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
    
    func goToHomeVC(){
        let homeVC = storyboard?.instantiateViewController(identifier: "homeVC") as? ViewController
        view.window?.rootViewController = homeVC
        view.window?.makeKeyAndVisible()
    }
    
    @IBAction func loginBtnPressed(_ sender: Any) {
        let error = validateFields();
        if error == nil{
            //get clean versions of the login info
            let cEmail = emailTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let cPw = pwTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            Auth.auth().signIn(withEmail: cEmail, password: cPw, completion: {(rst, err) in
                if err == nil{
                    self.goToHomeVC()
                }else{
                    self.showError(errMsg: "Error signing in: \(err?.localizedDescription)")
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

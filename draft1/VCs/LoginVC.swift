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
    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    //let bgImgView = UIImageView()
    let db = Firestore.firestore()
    let storageRef = Storage.storage().reference()
    var cEmail: String!
    var cPw: String!
    var curUser: User!
    var bgView: UIImageView!//background view
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (UserDefaults.standard.bool(forKey: "isDarkMode")) {
            bgView = Styling.setUpBg(vc: self, imgName: "bg6")
            Styling.styleTextField(emailTF)
            Styling.styleTextField(pwTF)
            Styling.styleHollowButton(signUpBtn, 20)
            Styling.navDarkMode(vc: self)
        }else{
            bgView = Styling.setUpBg(vc: self, imgName: "bg5")
            Styling.dayTextField(emailTF)
            Styling.dayTextField(pwTF)
            Styling.dayHollowButton(signUpBtn, 20)
            Styling.navDayMode(vc: self)
        }
        errorLabel.alpha = 0
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
    
    @IBAction func loginBtnPressed(_ sender: Any) {
        let error = validateFields();
        let queue = DispatchQueue(label: "dispatchQ", qos: .userInteractive)
        
        queue.sync {
            if error == nil{
                //get clean versions of the login info
                cEmail = emailTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                cPw = pwTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                Auth.auth().signIn(withEmail: self.cEmail, password: self.cPw, completion: {(rst, err) in
                    if err == nil{
                        self.performSegue(withIdentifier: "toHomeVC", sender: nil)
                    }else{
                        self.showError(errMsg: "\(err?.localizedDescription ?? "Error signing in.")")
                    }
                })
            }else{
                self.showError(errMsg: error!)
            }
        }//sync ends
    }
}

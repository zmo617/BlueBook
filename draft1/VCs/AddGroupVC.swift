//
//  AddGroupVC.swift
//  draft1
//
//  Created by Claire Mo on 6/14/20.
//  Copyright © 2020 Zongying Mo. All rights reserved.
//

import UIKit

class AddGroupVC: UIViewController {
   
    @IBOutlet weak var newTitleLabel: UILabel!
    @IBOutlet weak var newGroupTF: UITextField!
    
    //MARK:LOCAL PROPERTIES
    var mainVCDelegate: UIViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func createPressed(_ sender: Any) {
        let mainVC = mainVCDelegate as! ViewController
        mainVC.addGroup(newTitle: newGroupTF.text!)
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

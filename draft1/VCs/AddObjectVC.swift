//
//  AddObjectVC.swift
//  draft1
//
//  Created by Claire Mo on 6/14/20.
//  Copyright © 2020 Zongying Mo. All rights reserved.
//

import UIKit

class AddObjectVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var contentTxtView: UITextView!
    @IBOutlet weak var coverImgView: UIImageView!
    @IBOutlet weak var titleTxtField: UITextField!
    
    
    @IBOutlet weak var addPicBtn: UIButton!
    @IBOutlet weak var createBtn: UIButton!
    
    var groupTableDelegate: UIViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func importImg(_ sender: Any) {
        let imgPickerController = UIImagePickerController()
        imgPickerController.delegate = self
        
        
        let actionSheet = UIAlertController(title: "Photo Source", message: "Choose a source", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action: UIAlertAction) in
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                imgPickerController.sourceType = .camera
                self.present(imgPickerController, animated: true, completion: nil)
            }else{
                print("Camera not available")
            }
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Photo library", style: .default, handler: { (action: UIAlertAction) in
            imgPickerController.sourceType = .photoLibrary
            self.present(imgPickerController, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    //info is a dictionary containing img data.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //old name: info[UIImagePickerControllerOriginalImage]
        let img = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        coverImgView.image = img
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    //create button pressed
    @IBAction func createObject(_ sender: Any) {
        let groupVC = groupTableDelegate as! GroupTableVC
        groupVC.addObject(newCoverImg: coverImgView.image!, newTitle: titleTxtField.text!, newContent: contentTxtView.text)
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

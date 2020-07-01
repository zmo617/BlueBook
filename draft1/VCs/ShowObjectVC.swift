//
//  ShowObjectVC.swift
//  draft1
//
//  Created by Claire Mo on 6/14/20.
//  Copyright © 2020 Zongying Mo. All rights reserved.
//

import UIKit
import FirebaseUI
class ShowObjectVC: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    //MARK:LOCAL PROPERTIES
    var selectedImage: String?
    
    var currentObject: FavObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = currentObject.title
        let storageRef = Storage.storage().reference()
        let imgRef = storageRef.child(currentObject.coverImgPath)
        imageView.sd_setImage(with: imgRef)
        descriptionLabel.text = currentObject.content
        descriptionLabel.sizeToFit()
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

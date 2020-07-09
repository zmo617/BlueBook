//
//  ObjectCell.swift
//  draft1
//
//  Created by Claire Mo on 6/14/20.
//  Copyright © 2020 Zongying Mo. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI
class ObjectCell: UITableViewCell {
    
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var coverImgView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    func setObjectCell(sourceObj: FavObject){
        let storageRef = Storage.storage().reference()
        let imgRef = storageRef.child(sourceObj.coverImgPath)
        coverImgView.sd_setImage(with: imgRef)
        titleLabel.text = sourceObj.title
        titleLabel.textColor = UIColor.white
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}

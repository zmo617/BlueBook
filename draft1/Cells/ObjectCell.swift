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
    
    /*
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        let name = Notification.Name("darkModeChanged")
        NotificationCenter.default.addObserver(self, selector: #selector(enableDarkMode), name: name, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @objc func enableDarkMode() {
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        if (isDarkMode) {
            backgroundColor = UIColor(patternImage: UIImage(named: "bg6")!)
        } else  {
            backgroundColor = UIColor(patternImage: UIImage(named: "bg5")!)
        }
    }
    */
    
    func setObjectCell(sourceObj: FavObject){
        let storageRef = Storage.storage().reference()
        let imgRef = storageRef.child(sourceObj.coverImgPath)
        coverImgView.sd_setImage(with: imgRef)
        titleLabel.text = sourceObj.title
        titleLabel.textColor = UIColor.white
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}

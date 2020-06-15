//
//  ObjectCell.swift
//  draft1
//
//  Created by Claire Mo on 6/14/20.
//  Copyright © 2020 Zongying Mo. All rights reserved.
//

import UIKit

class ObjectCell: UITableViewCell {
    
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var coverImgView: UIImageView!
    @IBOutlet weak var titleButton: UIButton!
    
    func setObjectCell(sourceObj: FavObject){
        coverImgView.image = sourceObj.coverImage
        titleButton.setTitle(sourceObj.title, for: .normal)
        
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

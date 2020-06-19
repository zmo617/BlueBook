//
//  CollectionViewCell.swift
//  draft1
//
//  Created by Claire Mo on 6/14/20.
//  Copyright © 2020 Zongying Mo. All rights reserved.
//

import UIKit

@IBDesignable
class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var groupButton: UIButton!
    @IBOutlet weak var deleteView: UIVisualEffectView!
    
    
    
    
    var editMode: Bool = true{
        didSet{
            deleteView.isHidden = !editMode
            deleteView.layer.cornerRadius = deleteView.bounds.width/2.0
            deleteView.layer.masksToBounds = true
        }
        
    }
    @IBAction func deletePressed(_ sender: Any) {
        
    }
    
}

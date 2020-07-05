//
//  CollectionViewCell.swift
//  draft1
//
//  Created by Claire Mo on 6/14/20.
//  Copyright © 2020 Zongying Mo. All rights reserved.
//

import UIKit

protocol DataCollectionProtocol{
    //func passData(index: Int)
    func deleteData(index: Int)
}

class CollectionViewCell: UICollectionViewCell {
    //MARK:LOCAL PROPERTIES
    var delegate: DataCollectionProtocol!
    var index: IndexPath!
    
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var groupButton: UIButton!
    @IBOutlet weak var deleteView: UIVisualEffectView!

    //***Temp implementation of delete group
    @IBAction func deletePressed(_ sender: Any) {
         delegate.deleteData(index: index.row)
    }
    
    
    
}


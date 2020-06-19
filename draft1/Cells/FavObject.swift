//
//  FavObject.swift
//  draft1
//
//  Created by Claire Mo on 6/14/20.
//  Copyright © 2020 Zongying Mo. All rights reserved.
//

import UIKit
//Class for objects. Stores data for object properties.
//Separate from ObjectCell for better data management.
class FavObject: NSObject {
    
    //MARK:LOCAL PROPERTIES
    var coverImage: UIImage
    var title: String
    var content: String
    
    init(coverImage: UIImage, title: String, content: String){
        self.coverImage = coverImage
        self.title = title
        self.content = content
    }
    
}

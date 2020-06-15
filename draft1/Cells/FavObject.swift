//
//  FavObject.swift
//  draft1
//
//  Created by Claire Mo on 6/14/20.
//  Copyright © 2020 Zongying Mo. All rights reserved.
//

import UIKit

class FavObject: NSObject {
    var coverImage: UIImage
    var title: String
    var content: String
    
    init(coverImage: UIImage, title: String, content: String){
        self.coverImage = coverImage
        self.title = title
        self.content = content
    }
    
}

//
//  FavObject.swift
//  draft1
//
//  Created by Claire Mo on 6/14/20.
//  Copyright © 2020 Zongying Mo. All rights reserved.
//

import UIKit
import Foundation
import FirebaseFirestoreSwift
//Class for objects. Stores data for object properties.
//Separate from ObjectCell for better data management.
struct FavObject: Codable {
    var title: String
    var coverImgPath: String
    var content: String
    
    enum CodingKeys: String, CodingKey{
        case title
        case coverImgPath
        case content
    }
}

//
//  FavGroup.swift
//  draft1
//
//  Created by Claire Mo on 6/29/20.
//  Copyright © 2020 Zongying Mo. All rights reserved.
//

import Foundation
import FirebaseFirestoreSwift

struct FavGroup: Codable{
    //for getting data from Firebase, not logging in/signing up
    var title: String
   
    enum CodingKeys: String, CodingKey{
        case title
    }
}

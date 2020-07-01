//
//  User.swift
//  draft1
//
//  Created by Claire Mo on 6/27/20.
//  Copyright © 2020 Zongying Mo. All rights reserved.
//

import Foundation
import FirebaseFirestoreSwift

struct User: Codable{
    //for getting data from Firebase, not logging in/signing up
    var firstname: String
    var lastname: String
    var email: String
    var password: String
    
    enum CodingKeys: String, CodingKey{
        case firstname
        case lastname
        case email
        case password
    }
    
}

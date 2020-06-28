//
//  SnapshotExtensions.swift
//  draft1
//
//  Created by Claire Mo on 6/28/20.
//  Copyright © 2020 Zongying Mo. All rights reserved.
//

import Foundation
import FirebaseFirestore

extension QueryDocumentSnapshot{
    func decoded<T: Decodable>() throws -> T{
        //a json object is like a dictionary in swift
        let jsonData = try JSONSerialization.data(withJSONObject: data(), options: [])
        let object = try JSONDecoder().decode(T.self, from: jsonData)
        return object
    }
}

extension QuerySnapshot{
    func decoded<T: Decodable>() throws -> [T]{
        let objects: [T] = try documents.map({try $0.decoded()})
        return objects
    }
}

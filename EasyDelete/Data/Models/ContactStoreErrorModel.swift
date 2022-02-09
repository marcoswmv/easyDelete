//
//  EDErrorModel.swift
//  EasyDelete
//
//  Created by Marcos Vicente on 09/02/22.
//

import Foundation

struct ContactStoreErrorModel: Error {
    var title: String
    var reason: String
    var errorCode: Int
    
    static var mocked = ContactStoreErrorModel(title: "", reason: "", errorCode: 0)
}

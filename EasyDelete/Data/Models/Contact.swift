//
//  Contact.swift
//  EasyDelete
//
//  Created by Marcos Vicente on 04.08.2021.
//

import Foundation

class Contact: NSObject {
    
    var id: String
    var givenName: String
    var familyName: String
    var isDeleted: Bool
    
    init(givenName: String, familyName: String, isDeleted: Bool = false) {
        self.id = UUID().uuidString
        self.givenName = givenName
        self.familyName = familyName
        self.isDeleted = isDeleted
    }
}

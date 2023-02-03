//
//  ContactsCellViewModel.swift
//  EasyDelete
//
//  Created by Marcos Vicente on 31/01/23.
//

import Foundation

struct ContactCellViewModel {
    
    let identifier: String
    var name: String
    var phoneNumbers: [String]
    var isDeleted: Bool
    
    init(contact: Contact) {
        self.identifier = contact.identifier ?? ""
        self.name = (contact.givenName ?? "") + " " + (contact.familyName ?? "")
        if self.name.trimmingCharacters(in: .whitespaces).isEmpty {
            self.name = contact.phoneNumbers?.first ?? ""
        }
        self.phoneNumbers = contact.phoneNumbers ?? []
        self.isDeleted = contact.isContactDeleted
    }
}

extension ContactCellViewModel: Comparable {
    static func < (lhs: ContactCellViewModel, rhs: ContactCellViewModel) -> Bool {
        lhs.name < rhs.name
    }
    
    static func > (lhs: ContactCellViewModel, rhs: ContactCellViewModel) -> Bool {
        lhs.name > rhs.name
    }
}

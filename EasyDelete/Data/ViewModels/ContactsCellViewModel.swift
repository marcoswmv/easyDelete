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
    var deletionDate: Date
    
    var handleExpiration: ((String) -> Void)?
    
    init(contact: Contact, handleExpiration: ((String) -> Void)?) {
        self.identifier = contact.identifier 
        self.name = (contact.givenName ?? "") + " " + (contact.familyName ?? "")
        if self.name.trimmingCharacters(in: .whitespaces).isEmpty {
            self.name = contact.phoneNumbers?.first ?? ""
        }
        self.phoneNumbers = contact.phoneNumbers ?? []
        self.isDeleted = contact.isContactDeleted
        self.deletionDate = contact.deletionDate ?? Date()
        self.handleExpiration = handleExpiration
    }
}

extension ContactCellViewModel: Comparable {
    static func == (lhs: ContactCellViewModel, rhs: ContactCellViewModel) -> Bool {
        lhs.identifier == rhs.identifier &&
        lhs.name == rhs.name &&
        lhs.phoneNumbers == rhs.phoneNumbers &&
        lhs.isDeleted == rhs.isDeleted &&
        lhs.deletionDate == rhs.deletionDate
    }
    
    static func < (lhs: ContactCellViewModel, rhs: ContactCellViewModel) -> Bool {
        lhs.name < rhs.name
    }
    
    static func > (lhs: ContactCellViewModel, rhs: ContactCellViewModel) -> Bool {
        lhs.name > rhs.name
    }
}

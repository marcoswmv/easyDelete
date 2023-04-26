//
//  ContactModel.swift
//  EasyDelete
//
//  Created by Marcos Vicente on 04.08.2021.
//

import Foundation
import Contacts

final class ContactModel: ContactProtocol {
    var identifier: String
    var givenName: String?
    var familyName: String?
    var thumbnailPhoto: Data?
    var isContactDeleted: Bool
    var phoneNumbers: [String]
    var emails: [String]
    var deletionDate: Date?
    var organizationName: String?
    var jobTitle: String?
    var vCard: Data?
    
    init(identifier: String = "", 
         givenName: String? = nil, 
         familyName: String? = nil, 
         thumbnailPhoto: Data? = nil,
         isContactDeleted: Bool = false, 
         phoneNumbers: [String] = [], 
         emails: [String] = [], 
         deletionDate: Date? = nil,
         organizationName: String? = nil, 
         jobTitle: String? = nil,
         vCard: Data? = nil) {
        self.identifier = identifier
        self.givenName = givenName
        self.familyName = familyName
        self.thumbnailPhoto = thumbnailPhoto
        self.isContactDeleted = isContactDeleted
        self.phoneNumbers = phoneNumbers
        self.deletionDate = deletionDate
        self.emails = emails
        self.organizationName = organizationName
        self.jobTitle = jobTitle
        self.vCard = vCard
    }
    
    convenience init(contact: CNContact,
                     vCard: Data?) {
        self.init()
        self.identifier = contact.identifier
        self.givenName = !contact.givenName.isEmpty ? contact.givenName : contact.organizationName
        self.familyName = contact.familyName
        self.thumbnailPhoto = contact.imageData
        self.organizationName = contact.organizationName
        self.jobTitle = contact.jobTitle
        
        self.isContactDeleted = false
        self.deletionDate = nil
        
        for phoneNumber in contact.phoneNumbers {
            self.phoneNumbers.append(phoneNumber.value.stringValue)
        }
        
        for email in contact.emailAddresses {
            self.emails.append(email.value.description)
        }
        
        self.vCard = vCard
    }
}

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
    var imageDataAvailable: Bool
    var isContactDeleted: Bool
    var phoneNumbers: [String]?
    var emails: [String]?
    var deletionDate: Date?
    var organizationName: String?
    var jobTitle: String?
    
    init(identifier: String = "", 
         givenName: String? = nil, 
         familyName: String? = nil, 
         thumbnailPhoto: Data? = nil, 
         imageDataAvailable: Bool = false, 
         isContactDeleted: Bool = false, 
         phoneNumbers: [String]? = nil, 
         emails: [String]? = nil, 
         deletionDate: Date? = nil,
         organizationName: String? = nil, 
         jobTitle: String? = nil) {
        self.identifier = identifier
        self.givenName = givenName
        self.familyName = familyName
        self.thumbnailPhoto = thumbnailPhoto
        self.imageDataAvailable = imageDataAvailable
        self.isContactDeleted = isContactDeleted
        self.phoneNumbers = phoneNumbers
        self.deletionDate = deletionDate
        self.emails = emails
        self.organizationName = organizationName
        self.jobTitle = jobTitle
    }
    
    convenience init(contact: CNContact) {
        self.init()
        self.identifier = contact.identifier
        self.givenName = !contact.givenName.isEmpty ? contact.givenName : contact.organizationName
        self.familyName = contact.familyName
        self.imageDataAvailable = contact.imageDataAvailable
        self.thumbnailPhoto = (self.imageDataAvailable ? contact.imageData ?? Data() : Data())
        self.organizationName = contact.organizationName
        self.jobTitle = contact.jobTitle
        
        self.isContactDeleted = false
        self.deletionDate = nil
        
        for contact in contact.phoneNumbers {
            self.phoneNumbers?.append(contact.value.stringValue)
        }
        
        for email in contact.emailAddresses {
            self.emails?.append(email.value as String)
        }
    }
}

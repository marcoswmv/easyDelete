//
//  Contact.swift
//  EasyDelete
//
//  Created by Marcos Vicente on 04.08.2021.
//

import Foundation
import Contacts

class Contact: NSObject {
    
    var contactId: String
    var givenName: String
    var familyName: String

    var thumbnailPhoto: Data
    var imageDataAvailable: Bool
    
    var isDeleted: Bool
    
    var phoneNumbersLabels: [String] = [String]()
    var phoneNumbers: [String] = [String]()
    
    var emailsLabels: [String] = [String]()
    var emails: [String] = [String]()
    
    init(contact: CNContact) {
        self.contactId = contact.identifier
        self.givenName = !contact.givenName.isEmpty ? contact.givenName : contact.organizationName
        self.familyName = contact.familyName
        self.imageDataAvailable = contact.imageDataAvailable
        self.thumbnailPhoto = (self.imageDataAvailable ? contact.imageData ?? Data() : Data())
        self.isDeleted = false
        
        for contact in contact.phoneNumbers {
            self.phoneNumbersLabels.append(contact.label?.description ?? "Mobile")
            self.phoneNumbers.append(contact.value.stringValue)
        }
        
        for email in contact.emailAddresses {
            self.emailsLabels.append(email.label?.description ?? "Email")
            self.emails.append(email.value as String)
        }
    }
}

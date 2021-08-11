//
//  Contact.swift
//  EasyDelete
//
//  Created by Marcos Vicente on 04.08.2021.
//

import Foundation
import Contacts
import RealmSwift

class Contact: Object {
    
    @Persisted(primaryKey: true) var id: String
    @Persisted var givenName: String?
    @Persisted var familyName: String?

    @Persisted var thumbnailPhoto = Data()
    @Persisted var imageDataAvailable: Bool
    
    @Persisted var isDeleted: Bool
    
    @Persisted var phoneNumbersLabels: List<String>
    @Persisted var phoneNumbers: List<String>
    
    @Persisted var emailsLabels: List<String>
    @Persisted var emails: List<String>
    
    override init() {
        super.init()
    }
    
    convenience init(contact: CNContact) {
        self.init()
        self.id = contact.identifier
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

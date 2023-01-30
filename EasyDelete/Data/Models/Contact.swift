//
//  Contact.swift
//  EasyDelete
//
//  Created by Marcos Vicente on 04.08.2021.
//

import Foundation
import Contacts

class Contact {
    
    var identifier: String
    var givenName: String?
    var familyName: String?
    var thumbnailPhoto = Data()
    var imageDataAvailable: Bool
    var isDeleted: Bool
    var phoneNumbersLabels: [String]
    var phoneNumbers: [String]
    var emailsLabels: [String]
    var emails: [String]
    var jobTitle: String
    var dayOfDeletion: Date?
    var remainingDaysForDeletion: Int
    var scheduledDayForDeletion: Date?
    
    init(identifier: String = "", givenName: String? = nil, familyName: String? = nil, thumbnailPhoto: Data = Data(), imageDataAvailable: Bool = false, isDeleted: Bool = false, phoneNumbersLabels: [String] = [], phoneNumbers: [String] = [], emailsLabels: [String] = [], emails: [String] = [], jobTitle: String = "", dayOfDeletion: Date? = nil, remainingDaysForDeletion: Int = 0, scheduledDayForDeletion: Date? = nil) {
        self.identifier = identifier
        self.givenName = givenName
        self.familyName = familyName
        self.thumbnailPhoto = thumbnailPhoto
        self.imageDataAvailable = imageDataAvailable
        self.isDeleted = isDeleted
        self.phoneNumbersLabels = phoneNumbersLabels
        self.phoneNumbers = phoneNumbers
        self.emailsLabels = emailsLabels
        self.emails = emails
        self.jobTitle = jobTitle
        self.dayOfDeletion = dayOfDeletion
        self.remainingDaysForDeletion = remainingDaysForDeletion
        self.scheduledDayForDeletion = scheduledDayForDeletion
    }
    
    convenience init(contact: CNContact) {
        self.init()
        self.identifier = contact.identifier
        self.givenName = !contact.givenName.isEmpty ? contact.givenName : contact.organizationName
        self.familyName = contact.familyName
        self.imageDataAvailable = contact.imageDataAvailable
        self.thumbnailPhoto = (self.imageDataAvailable ? contact.imageData ?? Data() : Data())
        self.jobTitle = contact.jobTitle
        
        self.isDeleted = false
        self.dayOfDeletion = nil
        self.remainingDaysForDeletion = 0
        self.scheduledDayForDeletion = nil
        
        for contact in contact.phoneNumbers {
            self.phoneNumbersLabels.append(contact.label?.filter({ $0.isLetter || $0.isNumber || $0.isWhitespace }) ?? Consts.phoneNumbersLabelPlaceholder)
            self.phoneNumbers.append(contact.value.stringValue)
        }
        
        for email in contact.emailAddresses {
            self.emailsLabels.append(email.label?.filter({ $0.isLetter || $0.isNumber || $0.isWhitespace }) ?? Consts.emailsLabelPlaceholder)
            self.emails.append(email.value as String)
        }
    }
}

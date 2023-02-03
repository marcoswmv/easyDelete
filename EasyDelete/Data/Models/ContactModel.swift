//
//  ContactModel.swift
//  EasyDelete
//
//  Created by Marcos Vicente on 04.08.2021.
//

import Foundation
import Contacts

protocol ContactProtocol: AnyObject {
    var identifier: String { get set }
    var givenName: String? { get set }
    var familyName: String? { get set }
    var thumbnailPhoto: Data { get set }
    var imageDataAvailable: Bool { get set }
    var isContactDeleted: Bool { get set }
    var phoneNumbers: [String] { get set }
    var dayOfDeletion: Date? { get set }
    var remainingDaysForDeletion: Int { get set }
    var scheduledDayForDeletion: Date? { get set }
}

class ContactModel: ContactProtocol {
    
    var identifier: String
    var givenName: String?
    var familyName: String?
    var thumbnailPhoto = Data()
    var imageDataAvailable: Bool
    var isContactDeleted: Bool
    var phoneNumbers: [String]
    var dayOfDeletion: Date?
    var remainingDaysForDeletion: Int
    var scheduledDayForDeletion: Date?
    
    init(identifier: String = "", givenName: String? = nil, familyName: String? = nil, thumbnailPhoto: Data = Data(), imageDataAvailable: Bool = false, isContactDeleted: Bool = false, phoneNumbers: [String] = [], dayOfDeletion: Date? = nil, remainingDaysForDeletion: Int = 0, scheduledDayForDeletion: Date? = nil) {
        self.identifier = identifier
        self.givenName = givenName
        self.familyName = familyName
        self.thumbnailPhoto = thumbnailPhoto
        self.imageDataAvailable = imageDataAvailable
        self.isContactDeleted = isContactDeleted
        self.phoneNumbers = phoneNumbers
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
        
        self.isContactDeleted = false
        self.dayOfDeletion = nil
        self.remainingDaysForDeletion = 0
        self.scheduledDayForDeletion = nil
        
        for contact in contact.phoneNumbers {
            self.phoneNumbers.append(contact.value.stringValue)
        }
    }
}

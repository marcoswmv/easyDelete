//
//  Contact+CoreDataClass.swift
//  EasyDelete
//
//  Created by Marcos Vicente on 03/02/23.
//
//

import Foundation
import CoreData
import Contacts

@objc(Contact)
public class Contact: NSManagedObject {
    
    convenience init(contact: ContactProtocol, insertInto context: NSManagedObjectContext?) {
        let entity = NSEntityDescription.entity(forEntityName: "Contact", in: context!)
        self.init(entity: entity!, insertInto: context)
        
        self.identifier = contact.identifier
        self.givenName = contact.givenName
        self.familyName = contact.familyName
        self.thumbnailPhoto = contact.thumbnailPhoto
        self.imageDataAvailable = contact.imageDataAvailable
        self.isContactDeleted = contact.isContactDeleted
        self.phoneNumbers = contact.phoneNumbers
        self.dayOfDeletion = contact.dayOfDeletion
        self.remainingDaysForDeletion = Int64(contact.remainingDaysForDeletion)
        self.scheduledDayForDeletion = contact.scheduledDayForDeletion
    }

    convenience init(identifier: String = "", givenName: String? = nil, familyName: String? = nil, thumbnailPhoto: Data = Data(), imageDataAvailable: Bool = false, isContactDeleted: Bool = false, phoneNumbers: [String] = [], dayOfDeletion: Date? = nil, remainingDaysForDeletion: Int64 = 0, scheduledDayForDeletion: Date? = nil, insertInto context: NSManagedObjectContext?) {
        let entity = NSEntityDescription.entity(forEntityName: "Contact", in: context!)
        self.init(entity: entity!, insertInto: context)
        
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
    
    convenience init(contact: CNContact, insertInto context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: "Contact", in: context)
        self.init(entity: entity!, insertInto: context)
        
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
            self.phoneNumbers?.append(contact.value.stringValue)
        }
    }
}

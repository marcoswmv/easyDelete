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
    
    convenience init(contact: ContactProtocol, 
                     insertInto context: NSManagedObjectContext?) {
        let entity = NSEntityDescription.entity(forEntityName: "Contact", in: context!)
        self.init(entity: entity!, insertInto: context)
        
        self.identifier = contact.identifier
        self.givenName = contact.givenName
        self.familyName = contact.familyName
        self.thumbnailPhoto = contact.thumbnailPhoto
        self.isContactDeleted = contact.isContactDeleted
        self.phoneNumbers = contact.phoneNumbers
        self.deletionDate = contact.deletionDate
        self.organizationName = contact.organizationName
        self.jobTitle = contact.jobTitle
        self.emails = contact.emails
        self.vCard = contact.vCard
    }
}

extension Contact: ContactProtocol {
    
}

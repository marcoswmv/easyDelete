//
//  Contact+CoreDataProperties.swift
//  EasyDelete
//
//  Created by Marcos Vicente on 26/04/23.
//
//

import Foundation
import CoreData

extension Contact {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Contact> {
        return NSFetchRequest<Contact>(entityName: "Contact")
    }

    @NSManaged public var deletionDate: Date?
    @NSManaged public var emails: [String]
    @NSManaged public var familyName: String?
    @NSManaged public var givenName: String?
    @NSManaged public var identifier: String
    @NSManaged public var isContactDeleted: Bool
    @NSManaged public var jobTitle: String?
    @NSManaged public var organizationName: String?
    @NSManaged public var phoneNumbers: [String]
    @NSManaged public var thumbnailPhoto: Data?
    @NSManaged public var vCard: Data?

}

extension Contact: Identifiable {

}

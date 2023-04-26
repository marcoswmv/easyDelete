//
//  ContactProtocol.swift
//  EasyDelete
//
//  Created by Marcos Vicente on 03/02/23.
//

import Foundation

protocol ContactProtocol: AnyObject {
    var identifier: String { get set }
    var givenName: String? { get set }
    var familyName: String? { get set }
    var thumbnailPhoto: Data? { get set }
    var isContactDeleted: Bool { get set }
    var phoneNumbers: [String] { get set }
    var emails: [String] { get set }
    var deletionDate: Date? { get set }
    var organizationName: String? { get set }
    var jobTitle: String? { get set }
    var vCard: Data? { get set }
}

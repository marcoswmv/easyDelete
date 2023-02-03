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
    var imageDataAvailable: Bool { get set }
    var isContactDeleted: Bool { get set }
    var phoneNumbers: [String]? { get set }
    var dayOfDeletion: Date? { get set }
    var remainingDaysForDeletion: Int64 { get set }
    var scheduledDayForDeletion: Date? { get set }
    var organizationName: String? { get set }
    var jobTitle: String? { get set }
}

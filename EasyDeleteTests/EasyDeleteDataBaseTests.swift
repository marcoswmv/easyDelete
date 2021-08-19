//
//  EasyDeleteDBTests.swift
//  EasyDeleteTests
//
//  Created by Marcos Vicente on 13.08.2021.
//

import XCTest
import Contacts
import RealmSwift

@testable import EasyDelete

class EasyDeleteDataBaseTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        // Use an in-memory Realm identified by the name of the current test.
        // This ensures that each test can't accidentally access or modify the data
        // from other tests or the application itself, and because they're in-memory,
        // there's nothing that needs to be cleaned up.
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
    }
    
    func testUpdateAdd() {
        let contact = CNMutableContact()
        contact.givenName = "Marcos"
        contact.familyName = "Vicente"
        
        let testContact = Contact(contact: contact)
        testContact.isDeleted = false
        
        DataBaseManager.shared.update(with: testContact)
        let result = DataBaseManager.shared.getContactsList()
        guard let contactId = result.first?.identifier else { return }
        
        XCTAssertEqual(contactId, contact.identifier)
    }
    
    func testJustUpdate() {
        let contact = CNMutableContact()
        contact.givenName = "Marcos"
        contact.familyName = "Vicente"
        
        let testContact = Contact(contact: contact)
        DataBaseManager.shared.update(with: testContact)
        let result = DataBaseManager.shared.getContactsList()
        let testContactGivenName = result.first?.givenName
        
        let updatedContact = Contact()
        updatedContact.identifier = contact.identifier
        updatedContact.givenName = "Wilker"
        updatedContact.familyName = contact.familyName
        DataBaseManager.shared.update(with: updatedContact)
        let updatedContactGivenName = result.first?.givenName
        
        XCTAssertNotEqual(testContactGivenName, updatedContactGivenName)
        XCTAssertEqual(testContact.identifier, updatedContact.identifier)
    }
    
    func testFetch() {
        let contact = CNMutableContact()
        contact.givenName = "Marcos"
        contact.familyName = "Vicente"
        
        let testContact = Contact(contact: contact)
        testContact.isDeleted = false
        
        DataBaseManager.shared.update(with: testContact)
        let result = DataBaseManager.shared.getContactsList()
        
        XCTAssertEqual(result.count, 1)
    }
    
    func testDelete() {
        let contact = CNMutableContact()
        contact.givenName = "Marcos"
        contact.familyName = "Vicente"
        
        let testContact = Contact(contact: contact)
        testContact.isDeleted = false
        
        DataBaseManager.shared.update(with: testContact)
        
        DataBaseManager.shared.delete(contacts: [testContact])
        let result = DataBaseManager.shared.getContactsList()
        
        XCTAssertEqual(result.count, 0)
    }
    
    func testSetAsDeleted() {
        let contact = CNMutableContact()
        contact.givenName = "Marcos"
        contact.familyName = "Vicente"
        
        let testContact = Contact(contact: contact)
        DataBaseManager.shared.update(with: testContact)
        let result = DataBaseManager.shared.getContactsList()
        let resultTestContact = result.first?.isDeleted
        
        DataBaseManager.shared.setAsDeleted(contact: testContact)
        let deletedContact = result.first?.isDeleted
        
        XCTAssertNotEqual(resultTestContact, deletedContact)
    }
}

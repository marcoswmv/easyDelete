//
//  EasyDeleteTests.swift
//  EasyDeleteTests
//
//  Created by Marcos Vicente on 04.08.2021.
//

import XCTest
import Contacts
import RealmSwift

@testable import EasyDelete

class EasyDeleteDataSourceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        // Use an in-memory Realm identified by the name of the current test.
        // This ensures that each test can't accidentally access or modify the data
        // from other tests or the application itself, and because they're in-memory,
        // there's nothing that needs to be cleaned up.
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
    }
    
    func testGroupContactsBySections() {
        let contact = CNMutableContact()
        contact.givenName = "Marcos"
        contact.familyName = "Vicente"
        
        let testContact = Contact(contact: contact)
        testContact.isDeleted = false
        
        let contacts: [Contact] = [testContact]
        let sections = DataSourceManager.shared.groupContactsBySections(contacts)
        
        let placeholderContact = CNMutableContact()
        placeholderContact.givenName = ""
        placeholderContact.familyName = ""
        
        let (letter, names) = sections.first ?? ("", [Contact(contact: placeholderContact)])
        
        XCTAssertEqual(letter, String(contacts.first?.givenName?.first ?? " "))
        XCTAssertEqual(names, contacts)
    }
    
    func testSortIndexPathsInDescendingOrder() {
        let indexPaths = [IndexPath(row: 0, section: 1),
                          IndexPath(row: 0, section: 2),
                          IndexPath(row: 3, section: 1)]
        let sortedIndeces = DataSourceManager.shared.sortIndexPathsInDescendingOrder(indexPaths)
        
        let expectedResult = [indexPaths[1], indexPaths[2], indexPaths[0]]
        
        XCTAssertEqual(sortedIndeces, expectedResult)
    }
    
    func testExtractIndexPathArrayToDictionary() {
        let indexPaths = [IndexPath(row: 0, section: 1),
                          IndexPath(row: 0, section: 2),
                          IndexPath(row: 3, section: 1)]
        let extractedIndeces = DataSourceManager.shared.extractIndexPathArrayToDictionary(indexPaths: indexPaths)
        
        let expectedResult = [2: [0], 1: [0, 3]]
     
        XCTAssertEqual(extractedIndeces, expectedResult)
    }
    
    func testCreateSortedArrayOfTuples() {
        let sectionsDict = [1: [0, 3]]
        let sortedArray = DataSourceManager.shared.createSortedArrayOfTuples(sectionsDict: sectionsDict)
        let expectedResult = [(section: 1, rows: [3, 0])]
        
        XCTAssertEqual(sortedArray[0].section, expectedResult[0].section)
        XCTAssertEqual(sortedArray[0].rows, expectedResult[0].rows)
        
    }
    
    func testCreateNewIndexPathsArray() {
        let sortedArr = [(section: 1, rows: [3, 0])]
        let indexPathsArr = DataSourceManager.shared.createNewIndexPathsArray(resultArray: sortedArr)
        let expectedResult = [IndexPath(row: 3, section: 1), IndexPath(row: 0, section: 1)]
        
        XCTAssertEqual(indexPathsArr, expectedResult)
    }
    
    func testGroup() {
        let contact = CNMutableContact()
        contact.givenName = "Marcos"
        contact.familyName = "Vicente"
        
        let phoneNumbers = ["930694623", "923501557"]
        let emails = ["home@mv.ru", "work@hotmail.com"]
        
        for phone in phoneNumbers {
            contact.phoneNumbers.append(CNLabeledValue(
                                            label: "mobile",
                                            value: CNPhoneNumber(stringValue: phone)))
        }
        
        for email in emails {
            contact.emailAddresses.append(CNLabeledValue(label: "email", value: email as NSString))
        }
        
        let testContact = Contact(contact: contact)
        
        DataBaseManager.shared.update(with: testContact)
        
        let phoneNumbersExpectedResults = [(label:"mobile", item: "930694623"), (label:"mobile", item: "923501557")]
        let emailsExpectedResults = [(label:"email", item: "home@mv.ru"), (label:"email", item: "work@hotmail.com")]
        
        if let contact = DataBaseManager.shared.fetchContacts().first {
            let phoneNumbersResult = DataSourceManager.shared.group(items: contact.phoneNumbers, with: contact.phoneNumbersLabels)

            XCTAssertEqual(phoneNumbersResult.first?.label, phoneNumbersExpectedResults.first?.label)
            XCTAssertEqual(phoneNumbersResult.first?.item, phoneNumbersExpectedResults.first?.item)
            
            let emailsResult = DataSourceManager.shared.group(items: contact.emails, with: contact.emailsLabels)
            
            XCTAssertEqual(emailsResult.first?.label, emailsExpectedResults.first?.label)
            XCTAssertEqual(emailsResult.first?.item, emailsExpectedResults.first?.item)
        }
    }
}

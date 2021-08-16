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
}

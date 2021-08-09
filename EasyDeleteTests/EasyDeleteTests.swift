//
//  EasyDeleteTests.swift
//  EasyDeleteTests
//
//  Created by Marcos Vicente on 04.08.2021.
//

import XCTest

@testable import EasyDelete

class EasyDeleteTests: XCTestCase {

    func testGroupContactsBySections() {
        let contacts: [Contact] = [Contact(givenName: "Marcos", familyName: "Vicente")]
        let sections = DataSourceManager.shared.groupContactsBySections(contacts, deleted: false)
        
        let (letter, names) = sections.first ?? ("", [Contact(givenName: "", familyName: "", isDeleted: false)])
        
        XCTAssertEqual(letter, String(contacts.first?.givenName.first ?? " "))
        XCTAssertEqual(names, contacts)
    }
    
    func testFilter() {
        let contacts: [Contact] = [Contact(givenName: "Marcos", familyName: "Vicente"),
                                   Contact(givenName: "Cássia", familyName: "Carmo", isDeleted: true)]
        let expectedResult = [contacts[0]]
        
        XCTAssertEqual(DataSourceManager.shared.filter(contacts, deleted: false), expectedResult)
    }

    func testSort() {
        let contacts: [Contact] = [Contact(givenName: "Marcos", familyName: "Vicente"),
                                   Contact(givenName: "Cássia", familyName: "Carmo")]
        let expectedResult = [contacts[1],
                              contacts[0]]
        
        XCTAssertEqual(DataSourceManager.shared.sortInAscendingOrder(contacts), expectedResult)
    }
    
    func testListContacts() {
        let contacts: [Contact] = [Contact(givenName: "Marcos", familyName: "Vicente"),
                                   Contact(givenName: "Cássia", familyName: "Carmo")]
        let listedContacts = DataSourceManager.shared.listContacts(contacts, deleted: false)
        
        let expectedResult = [contacts[1], contacts[0]]
        
        XCTAssertEqual(listedContacts, expectedResult)
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

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
        let sections = Helpers.groupContactsBySections(contacts, deleted: false)
        
        let (letter, names) = sections.first ?? ("", [Contact(givenName: "", familyName: "", isDeleted: false)])
        
        XCTAssertEqual(letter, String(contacts.first?.givenName.first ?? " "))
        XCTAssertEqual(names, contacts)
    }
    
    func testFilter() {
        let contacts: [Contact] = [Contact(givenName: "Marcos", familyName: "Vicente"),
                                   Contact(givenName: "Cássia", familyName: "Carmo", isDeleted: true)]
        let expectedResult = [contacts[0]]
        
        XCTAssertEqual(Helpers.filter(contacts, deleted: false), expectedResult)
    }

    func testSort() {
        let contacts: [Contact] = [Contact(givenName: "Marcos", familyName: "Vicente"),
                                   Contact(givenName: "Cássia", familyName: "Carmo")]
        let expectedResult = [contacts[1],
                              contacts[0]]
        
        XCTAssertEqual(Helpers.sort(contacts), expectedResult)
    }
}

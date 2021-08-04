//
//  EasyDeleteTests.swift
//  EasyDeleteTests
//
//  Created by Marcos Vicente on 04.08.2021.
//

import XCTest

@testable import EasyDelete

class EasyDeleteTests: XCTestCase {

    func testGenerateSections() {
        let contacts: [Contact] = [Contact(givenName: "Marcos", familyName: "Vicente")]
        let sections = Helpers.generateSections(from: contacts)
        
        let (letter, names) = sections.first ?? ("", [Contact(givenName: "", familyName: "")])
        
        XCTAssertEqual(letter, String(contacts.first?.givenName.first ?? " "))
        XCTAssertEqual(names, contacts)
    }

}

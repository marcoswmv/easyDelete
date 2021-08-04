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
        let contacts: [String] = ["Marcos Vicente"]
        let sections = Helpers.generateSections(from: contacts)
        
        let (letter, names) = sections.first ?? ("", [""])
        
        XCTAssertEqual(letter, String(contacts.first?.first ?? " "))
        XCTAssertEqual(names, contacts)
    }

}

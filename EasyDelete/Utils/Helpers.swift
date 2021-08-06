//
//  HelperMethods.swift
//  EasyDelete
//
//  Created by Marcos Vicente on 04.08.2021.
//

import UIKit

struct Helpers {
    
    typealias ContactSectionsType = [(letter: String, names: [Contact])]
    
    static func generateSections(from contacts: [Contact]) -> ContactSectionsType {
        return Dictionary(grouping: contacts) { (name) -> Character in
            return name.givenName.first!
        }
        .map { (key: Character, value: [Contact]) -> (letter: String, names: [Contact]) in
            (letter: String(key), names: value)
        }
        .sorted { (left, right) -> Bool in
            left.letter < right.letter
        }
    }
}

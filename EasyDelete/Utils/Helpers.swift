//
//  HelperMethods.swift
//  EasyDelete
//
//  Created by Marcos Vicente on 04.08.2021.
//

import UIKit

struct Helpers {
    
    static func generateSections(from contacts: [String]) -> [(letter: String, names: [String])] {
        return Dictionary(grouping: contacts) { (name) -> Character in
            return name.first!
        }
        .map { (key: Character, value: [String]) -> (letter: String, names: [String]) in
            (letter: String(key), names: value)
        }
        .sorted { (left, right) -> Bool in
            left.letter < right.letter
        }
    }
}

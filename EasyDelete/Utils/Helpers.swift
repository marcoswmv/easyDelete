//
//  HelperMethods.swift
//  EasyDelete
//
//  Created by Marcos Vicente on 04.08.2021.
//

import UIKit

struct Helpers {
    
    typealias ContactSectionsType = [(letter: String, names: [Contact])]
    
    static let dummyContactData: [Contact] = [
        Contact(givenName: "Marcos", familyName: "Vicente"),
        Contact(givenName: "Marta", familyName: "José"),
        Contact(givenName: "Mario", familyName: "Cruz"),
        Contact(givenName: "Cássia", familyName: "Carmo"),
        Contact(givenName: "Walter", familyName: "Morgado"),
        Contact(givenName: "Danilson", familyName: "Pombal"),
        Contact(givenName: "Sidney", familyName: "Ribeiro")]
    
    static func filter(_ contacts: [Contact], deleted: Bool) -> [Contact] {
        return contacts.filter { $0.isDeleted == deleted }
    }
    
    static func sort(_ contacts: [Contact]) -> [Contact] {
        return contacts.sorted { $0.givenName < $1.givenName }
    }
    
    static func groupContactsBySections(_ contacts: [Contact], deleted: Bool) -> ContactSectionsType {
        let filteredContacts = filter(contacts, deleted: deleted)
        let sortedContacts = sort(filteredContacts)
        
        return Dictionary(grouping: sortedContacts) { (name) -> Character in
            return name.givenName.first!
        }
        .map { (key: Character, value: [Contact]) -> (letter: String, names: [Contact]) in
            (letter: String(key), names: value)
        }
        .sorted { $0.letter < $1.letter }
    }
}

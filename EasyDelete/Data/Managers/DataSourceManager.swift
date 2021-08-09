//
//  HelperMethods.swift
//  EasyDelete
//
//  Created by Marcos Vicente on 04.08.2021.
//

import UIKit

struct DataSourceManager {
    
    static let dummyContactData: Consts.ContactsListType = [
        Contact(givenName: "Marcos", familyName: "Vicente"),
        Contact(givenName: "Marta", familyName: "José"),
        Contact(givenName: "Mario", familyName: "Cruz"),
        Contact(givenName: "Cássia", familyName: "Carmo"),
        Contact(givenName: "Walter", familyName: "Morgado"),
        Contact(givenName: "Danilson", familyName: "Pombal"),
        Contact(givenName: "Sidney", familyName: "Ribeiro")]
    
    static func filter(_ contacts: Consts.ContactsListType, deleted: Bool) -> Consts.ContactsListType {
        return contacts.filter { $0.isDeleted == deleted }
    }
    
    static func sort(_ contacts: Consts.ContactsListType) -> Consts.ContactsListType {
        return contacts.sorted { $0.givenName < $1.givenName }
    }
    
    static func groupContactsBySections(_ contacts: Consts.ContactsListType, deleted: Bool) -> Consts.ContactSectionsType {
        let filteredContacts = filter(contacts, deleted: deleted)
        let sortedContacts = sort(filteredContacts)
        
        return Dictionary(grouping: sortedContacts) { (name) -> Character in
            return name.givenName.first!
        }
        .map { (key: Character, value: Consts.ContactsListType) -> (letter: String, names: ContactsListType) in
            (letter: String(key), names: value)
        }
        .sorted { $0.letter < $1.letter }
    }
    
    static func listContacts(_ contacts: Consts.ContactsListType, deleted: Bool) -> Consts.ContactsListType {
        let filteredContacts = filter(contacts, deleted: deleted)
        return sort(filteredContacts)
    }
}

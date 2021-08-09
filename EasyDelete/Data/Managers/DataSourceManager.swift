//
//  HelperMethods.swift
//  EasyDelete
//
//  Created by Marcos Vicente on 04.08.2021.
//

import UIKit

class DataSourceManager {
    
    static let shared = DataSourceManager()
    
    private init() { }
    
    var dummyContactData: ContactsListType = [
        Contact(givenName: "Marcos", familyName: "Vicente"),
        Contact(givenName: "Marta", familyName: "José"),
        Contact(givenName: "Mario", familyName: "Cruz"),
        Contact(givenName: "Cássia", familyName: "Carmo"),
        Contact(givenName: "Walter", familyName: "Morgado"),
        Contact(givenName: "Danilson", familyName: "Pombal"),
        Contact(givenName: "Sidney", familyName: "Ribeiro")]
    
    func filter(_ contacts: ContactsListType, deleted: Bool) -> ContactsListType {
        return contacts.filter { $0.isDeleted == deleted }
    }
    
    func sortInAscendingOrder(_ contacts: ContactsListType) -> ContactsListType {
        return contacts.sorted { $0.givenName < $1.givenName }
    }
    
    func groupContactsBySections(_ contacts: ContactsListType, deleted: Bool) -> ContactSectionsType {
        let filteredContacts = filter(contacts, deleted: deleted)
        let sortedContacts = sortInAscendingOrder(filteredContacts)
        let resultDict = Dictionary(grouping: sortedContacts) { (name) -> Character in
            return name.givenName.first!
        }
        .map { (key: Character, value: ContactsListType) -> (letter: String, names: ContactsListType) in
            (letter: String(key), names: value)
        }
        .sorted { $0.letter < $1.letter }
        
        return resultDict
    }
    
    func listContacts(_ contacts: ContactsListType, deleted: Bool) -> ContactsListType {
        let filteredContacts = filter(contacts, deleted: deleted)
        let sortedContacts = sortInAscendingOrder(filteredContacts)
        
        return sortedContacts
    }
    
    func recover(contact: Contact) {
        if dummyContactData.contains(where: { $0.id == contact.id && $0.isDeleted != contact.isDeleted }) {
            if let index = dummyContactData.firstIndex(of: contact) {
                dummyContactData[index] = contact
            }
        }
    }
    
    func sortIndexPathsInDescendingOrder(_ indexPaths: [IndexPath]) -> [IndexPath] {
        let sectionsDict = extractIndexPathArrayToDictionary(indexPaths: indexPaths)
        let resultArray = createSortedArrayOfTuples(sectionsDict: sectionsDict)
        
        return createNewIndexPathsArray(resultArray: resultArray)
    }
    
    func extractIndexPathArrayToDictionary(indexPaths: [IndexPath]) -> [Int: [Int]] {
        var sectionsDict: [Int: [Int]] = [:]
        
        for indexPath in indexPaths {
            if sectionsDict.contains(where: { $0.key == indexPath.section }) {
                sectionsDict[indexPath.section]?.append(indexPath.row)
            } else {
                sectionsDict.updateValue([indexPath.row], forKey: indexPath.section)
            }
        }
        
        return sectionsDict
    }
    
    func createSortedArrayOfTuples(sectionsDict: [Int: [Int]]) -> [(section: Int, rows: [Int])] {
        return sectionsDict.map { (key: Int, value: [Int]) -> (section: Int, rows: [Int]) in
            let sortedValues = value.sorted(by: >)
            return (section: key, rows: sortedValues)
        }
        .sorted(by: { $0.section > $1.section })
    }
    
    func createNewIndexPathsArray(resultArray: [(section: Int, rows: [Int])]) -> [IndexPath] {
        var resultIndexPaths: [IndexPath] = []
        
        for result in resultArray {
            for row in result.rows {
                resultIndexPaths.append(IndexPath(row: row, section: result.section))
            }
        }
        
        return resultIndexPaths
    }
}

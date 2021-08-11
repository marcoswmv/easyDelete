//
//  HelperMethods.swift
//  EasyDelete
//
//  Created by Marcos Vicente on 04.08.2021.
//

import UIKit

class DataSourceManager {
    
    static let shared = DataSourceManager()
    
    var contactArr: EDTypes.ContactsList = []
    
    private init() { }
    
    func filter(_ contacts: EDTypes.ContactsList, deleted: Bool) -> EDTypes.ContactsList {
        return contacts.filter { $0.isDeleted == deleted }
    }
    
    func sortInAscendingOrder(_ contacts: EDTypes.ContactsList) -> EDTypes.ContactsList {
        return contacts.sorted { $0.givenName < $1.givenName }
    }
    
    func groupContactsBySections(_ contacts: EDTypes.ContactsList, deleted: Bool) -> EDTypes.GroupedContacts {
        let filteredContacts = filter(contacts, deleted: deleted)
        let sortedContacts = sortInAscendingOrder(filteredContacts)
        let resultDict = Dictionary(grouping: sortedContacts) { (name) -> String in
            guard let firstLetter = name.givenName.first?.uppercased() else { return "" }
            return firstLetter
        }
        .map { (key: String, value: EDTypes.ContactsList) -> (letter: String, names: EDTypes.ContactsList) in
            (letter: key, names: value)
        }
        .sorted { $0.letter < $1.letter }
        
        return resultDict
    }
    
    func listContacts(_ contacts: EDTypes.ContactsList, deleted: Bool) -> EDTypes.ContactsList {
        let filteredContacts = filter(contacts, deleted: deleted)
        let sortedContacts = sortInAscendingOrder(filteredContacts)
        
        return sortedContacts
    }
    
    func recover(contact: Contact) {
        if contactArr.contains(where: { $0.contactId == contact.contactId && $0.isDeleted != contact.isDeleted }) {
            if let index = contactArr.firstIndex(of: contact) {
                contactArr[index] = contact
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

//
//  HelperMethods.swift
//  EasyDelete
//
//  Created by Marcos Vicente on 04.08.2021.
//

import UIKit
import RealmSwift

class DataSourceManager {
    
    static let shared = DataSourceManager()
    
    var contactArr: EDTypes.ContactsList = []
    
    private init() { }
    
    func groupContactsBySections(_ contacts: Results<Contact>) -> EDTypes.GroupedContacts {
        let contactsArr = getContactsArray(from: contacts)
        
        let resultDict = Dictionary(grouping: contactsArr) { (name) -> String in
            guard let firstLetter = name.givenName?.first?.uppercased() else { return "" }
            return firstLetter
        }
        .map { (key: String, value: EDTypes.ContactsList) -> (letter: String, names: EDTypes.ContactsList) in
            (letter: key, names: value)
        }
        .sorted { $0.letter < $1.letter }
        
        return resultDict
    }
    
    func getContactsArray(from contacts: Results<Contact>) -> EDTypes.ContactsList {
        var resultArr = EDTypes.ContactsList()
        
        for contact in contacts {
            resultArr.append(contact)
        }
        
        return resultArr
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

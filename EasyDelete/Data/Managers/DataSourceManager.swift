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
    
    func groupContactsBySections(_ contacts: EDTypes.ContactsList) -> EDTypes.GroupedContacts {
        return Dictionary(grouping: contacts) { (name) -> String in
            guard let firstLetter = name.givenName?.first?.uppercased() else { return "" }
            return firstLetter
        }
        .map { (key: String, value: EDTypes.ContactsList) -> (letter: String, names: EDTypes.ContactsList) in
            (letter: key, names: value)
        }
        .sorted { $0.letter < $1.letter }
    }
    
    func sortIndexPathsInDescendingOrder(_ indexPaths: EDTypes.IndexPaths) -> EDTypes.IndexPaths {
        let sectionsDict = extractIndexPathArrayToDictionary(indexPaths: indexPaths)
        let resultArray = createSortedArrayOfTuples(sectionsDict: sectionsDict)
        
        return createNewIndexPathsArray(resultArray: resultArray)
    }
    
    func extractIndexPathArrayToDictionary(indexPaths: EDTypes.IndexPaths) -> EDTypes.ExtractedIndexPaths {
        var sectionsDict: EDTypes.ExtractedIndexPaths = [:]
        
        for indexPath in indexPaths {
            if sectionsDict.contains(where: { $0.key == indexPath.section }) {
                sectionsDict[indexPath.section]?.append(indexPath.row)
            } else {
                sectionsDict.updateValue([indexPath.row], forKey: indexPath.section)
            }
        }
        
        return sectionsDict
    }
    
    func createSortedArrayOfTuples(sectionsDict: EDTypes.ExtractedIndexPaths) -> EDTypes.GroupedIndexPaths {
        return sectionsDict.map { (key: Int, value: [Int]) -> (section: Int, rows: [Int]) in
            let sortedValues = value.sorted(by: >)
            return (section: key, rows: sortedValues)
        }
        .sorted(by: { $0.section > $1.section })
    }
    
    func createNewIndexPathsArray(resultArray: EDTypes.GroupedIndexPaths) -> EDTypes.IndexPaths {
        var resultIndexPaths: EDTypes.IndexPaths = []
        
        for result in resultArray {
            for row in result.rows {
                resultIndexPaths.append(IndexPath(row: row, section: result.section))
            }
        }
        
        return resultIndexPaths
    }
    
    func nameAttributedString(contact: Contact) -> NSMutableAttributedString {
        var attributedString = NSMutableAttributedString(string: "")
        
        if let givenName = contact.givenName {
            attributedString = NSMutableAttributedString(string: "\(givenName) ")
            let attributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17)]
            let boldString = NSMutableAttributedString(string: contact.familyName ?? "", attributes: attributes)
            
            attributedString.append(boldString)
        }
        
        return attributedString
    }
}

//
//  CustomTypes.swift
//  EasyDelete
//
//  Created by Marcos Vicente on 09.08.2021.
//

import Foundation

struct EDTypes {
    
    typealias ContactsList = [Contact]
    typealias GroupedContacts = [(letter: String, names: ContactsList)]
    typealias ContactsRequestResultHandler = (Result<Contact, Error>) -> Void
    typealias ContactsRequestResult = Result<Contact, Error>
    typealias IndexPaths = [IndexPath]
    typealias ExtractedIndexPaths = [Int: [Int]]
    typealias GroupedIndexPaths = [(section: Int, rows: [Int])]
}

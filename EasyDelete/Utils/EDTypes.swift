//
//  CustomTypes.swift
//  EasyDelete
//
//  Created by Marcos Vicente on 09.08.2021.
//

import RealmSwift

struct EDTypes {
    
    typealias ContactsList = [Contact]
    typealias ContactDetailsList = [(label: String, item: String)]
    typealias ContactItemsList = List<String>
    typealias GroupedContacts = [(letter: String, names: ContactsList)]
    typealias ContactsRequestResultHandler = (Result<Contact, ContactStoreErrorModel>) -> Void
    typealias ContactsRequestResult = Result<Contact, ContactStoreErrorModel>
    typealias IndexPaths = [IndexPath]
    typealias ExtractedIndexPaths = [Int: [Int]]
    typealias GroupedIndexPaths = [(section: Int, rows: [Int])]
    typealias DataBaseFetchRequest = Results<Contact>
}

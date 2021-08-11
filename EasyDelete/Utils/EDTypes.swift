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
    typealias ContactsRequestResult = (Result<Contact, Error>) -> Void
}

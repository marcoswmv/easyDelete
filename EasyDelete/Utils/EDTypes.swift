//
//  CustomTypes.swift
//  EasyDelete
//
//  Created by Marcos Vicente on 09.08.2021.
//

import Foundation

typealias ContactsRequestCompletionBlock = (Result<[ContactModel], ContactStoreError>) -> Void
typealias GroupedContactsViewModels = [(letter: String, names: [ContactCellViewModel])]

typealias ExtractedIndexPaths = [Int: [Int]]
typealias GroupedIndexPaths = [(section: Int, rows: [Int])]

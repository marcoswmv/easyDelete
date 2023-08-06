//
//  ContactsListViewModel.swift
//  EasyDelete
//
//  Created by Marcos Vicente on 24/08/22.
//

import UIKit
import Combine
import CoreData

final class ContactsListViewModel {
    
//    let context: NSManagedObjectContext = ContactsPersistence.shared.container.viewContext
    private let contactsStore: ContactsStoreProtocol = ContactsStore()
//    private let databaseManager: DatabaseManagerProtocol = DatabaseManager()
    
    private var localContactsViewModels: GroupedContactsViewModels = []
    private var filteredContactsViewModels: GroupedContactsViewModels = []
    private var isSearching: Bool = false
    
    @Published var error: Error?
    @Published var contactsViewModels: GroupedContactsViewModels = []
    
    func fetchContacts(completionHandler: (() -> Void)? = nil) {
        contactsStore.fetchContacts { [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success(let contacts):
                ContactsPersistence.shared.importContacts(from: contacts)
                self.generateViewModels()
            case .failure(let error):
                self.error = error
            }
            completionHandler?()
        }
    }
    
    func deleteContact(with deletedContactViewModelID: String, permanently: Bool = false) {
        if let contactModelToDelete = retrieveContactsFromDatabase().first(where: { $0.identifier == deletedContactViewModelID }) {
            if permanently, contactModelToDelete.isContactDeleted {
                // Delete from database
                ContactsPersistence.shared.deleteContacts([contactModelToDelete])
            } else {
                // Save deleted to data base
                ContactsPersistence.shared.setIsDeleted(true, contact: contactModelToDelete)
                // Delete from Contacts store
                contactsStore.delete(contact: contactModelToDelete) { [weak self] error in
                    self?.error = error
                }
            }
        }
        
        generateViewModels()
    }
    
    func recoverContact(with deletedContactViewModelID: String) {
        if let contactModelToRecover = retrieveContactsFromDatabase().first(where: { $0.identifier == deletedContactViewModelID }) {
            ContactsPersistence.shared.setIsDeleted(false, contact: contactModelToRecover)
            
            // Add to the contact store
            contactsStore.add(contact: contactModelToRecover) { [weak self] error in
                self?.error = error
            }
        }
        
        generateViewModels()
    }
    
    func startQuery(with text: String?, ofDeleted: Bool = false) {
        if let text, text.isEmpty == false {
            isSearching = true
            filteredContactsViewModels = groupContactsBySections(localContactsViewModels
                .filter({ $0.names.allSatisfy({ $0.isDeleted == ofDeleted })})
                .flatMap({ $0.names })
                .filter({ $0.name.lowercased().contains(text.lowercased()) }))
            
            contactsViewModels = isSearching ? filteredContactsViewModels : localContactsViewModels
        } else {
            isSearching = false
            generateViewModels()
        }
    }
}

// MARK: - Helpers

extension ContactsListViewModel {
    private func groupContactsBySections(_ contacts: [ContactCellViewModel]) -> GroupedContactsViewModels {
        return Dictionary(grouping: contacts) { (name) -> String in
            guard let firstLetter = name.name.first, firstLetter.isLetter else { return "" }
            return firstLetter.uppercased()
        }
        .map { (key: String, value: [ContactCellViewModel]) -> (letter: String, names: [ContactCellViewModel]) in
            (letter: key, names: value.sorted { $0.name.lowercased() < $1.name.lowercased() })
        }
        .sorted { $0.letter < $1.letter }
    }
    
    private func generateViewModels() {
        let retrievedContactModels = retrieveContactsFromDatabase()
        localContactsViewModels = groupContactsBySections(retrievedContactModels.map { ContactCellViewModel(contact: $0) { [weak self] identifier in
            self?.deleteContact(with: identifier, permanently: true)
        }})
        
        contactsViewModels = isSearching ? filteredContactsViewModels : localContactsViewModels
    }
    
    private func retrieveContactsFromDatabase() -> [Contact] {
        do {
            return try ContactsPersistence.shared.retrieveContacts()
        } catch {
            self.error = error
        }
        return []
    }
}

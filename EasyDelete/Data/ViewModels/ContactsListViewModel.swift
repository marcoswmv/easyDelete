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
    
    let context: NSManagedObjectContext? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    private let contactsStore: ContactsStoreProtocol = ContactsStore()
    private let databaseManager: DatabaseManagerProtocol = DatabaseManager()
    
    @Published var error: Error?
    @Published var contactsViewModels: GroupedContactsViewModels = []
    
    func fetchContacts(completionHandler: (() -> Void)? = nil) {
        contactsStore.fetchContacts { [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success(let contacts):
                contacts.forEach { self.databaseManager.create(contact: $0) }
                self.generateViewModels()
                // self.databaseManager.deleteAll()
            case .failure(let error):
                self.error = error
            }
            completionHandler?()
        }
    }
    
    func deleteContact(with deletedContactViewModelID: String, permanently: Bool = false) {
        let retrievedContactModels = retrieveContactsFromDatabase()
        
        if let contactModelToDelete = retrievedContactModels.first(where: { $0.identifier == deletedContactViewModelID }) {
            if permanently, contactModelToDelete.isContactDeleted {
                // Delete from database
                databaseManager.delete(contact: contactModelToDelete)
            } else {
                // Save deleted to data base
                databaseManager.setAsDeleted(contact: contactModelToDelete)
                // Delete from Contacts store
                contactsStore.delete(contactWith: contactModelToDelete.identifier ?? "")
            }
        }
        
        generateViewModels()
    }
    
    func startQuery(with text: String) {
        let filteredViewModels = contactsViewModels
            .filter({ $0.names.contains(where: { $0.name.lowercased().hasPrefix(text.lowercased())}) })
        // let groupedContacts = self.groupContactsBySections(filteredViewModels)
        self.contactsViewModels = filteredViewModels
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
            (letter: key, names: value)
        }
        .sorted { $0.letter < $1.letter }
    }
    
    private func generateViewModels() {
        let retrievedContactModels = retrieveContactsFromDatabase()
        self.contactsViewModels = self.groupContactsBySections(retrievedContactModels.map { ContactCellViewModel(contact: $0)})
    }
    
    private func retrieveContactsFromDatabase() -> [Contact] {
        do {
            return try databaseManager.retrieveContacts()
        } catch {
            self.error = error
        }
        return []
    }
}

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
    
    private let contactsStore: ContactsStoreProtocol = ContactsStore()
    
    private var localContactsViewModels: GroupedContactsViewModels = []
    private var filteredContactsViewModels: GroupedContactsViewModels = []
    private var isSearching: Bool = false
    
    @Published var error: Error?
    @Published var successMessage: (ContactStoreSuccessfulAction, String)?
    @Published var contactsViewModels: GroupedContactsViewModels = []
    
    func fetchContacts(completionHandler: (() -> Void)? = nil) {
        contactsStore.fetchContacts { [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success(let contacts):
                ContactsPersistence.shared.importContacts(from: contacts) { [weak self] in
                    self?.generateViewModels()
                }
            case .failure(let error):
                self.error = error
            }
            completionHandler?()
        }
    }
    
    func deleteContacts(with deletedContactViewModelIDs: [String], permanently: Bool = false) {
        let contactsToDelete = ContactsPersistence.shared.getContactsForContactIDs(deletedContactViewModelIDs)
        if permanently {
            // Delete from database
            ContactsPersistence.shared.deleteContacts(contactsToDelete) { [weak self] in
                self?.successMessage = (.delete, Strings.Text.deletionSuccessfulText)
            }
        } else {
            // Save deleted to data base
            ContactsPersistence.shared.setIsDeleted(true, contacts: contactsToDelete) { [weak self] in
                guard let `self` = self else { return }
                self.generateViewModels()
            }
            
            // Delete from Contacts store
            contactsStore.delete(contacts: contactsToDelete) { [weak self] result in
                switch result {
                case .success(let type): 
                    if type == .delete {
                        self?.successMessage = (type, Strings.Text.deletionSuccessfulText)
                    }
                case .failure(let error):
                    self?.error = error
                }
            }
        }
    }
    
    func recoverContact(with recoveredContactViewModelIDs: [String]) {
        let contactsToRecover = ContactsPersistence.shared.getContactsForContactIDs(recoveredContactViewModelIDs)
        
        ContactsPersistence.shared.setIsDeleted(false, contacts: contactsToRecover) { [weak self] in
            guard let `self` = self else { return }
            self.generateViewModels()
        }
        
        // Add to the contact store
        contactsStore.add(contacts: contactsToRecover) { [weak self] result in
            switch result {
            case .success(let type): 
                if type == .add {
                    self?.successMessage = (type, Strings.Text.recoverySuccessfulText)
                }
            case .failure(let error):
                self?.error = error
            }
        }
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
            guard let firstLetter = name.name.first(where: { $0.isLetter }) else { return "" }
            return firstLetter.uppercased()
        }
        .map { (key: String, value: [ContactCellViewModel]) -> (letter: String, names: [ContactCellViewModel]) in
            (letter: key, names: value.sorted { $0.name.lowercased() < $1.name.lowercased() })
        }
        .sorted { $0.letter < $1.letter }
    }
    
    private func generateViewModels() {
        let retrievedContactModels = ContactsPersistence.shared.retrieveContacts()
        localContactsViewModels = groupContactsBySections(
            retrievedContactModels.map { 
                ContactCellViewModel(contact: $0) { [weak self] identifier in
                    self?.deleteContacts(with: [identifier], permanently: true)
                }
            }
        )
        
        contactsViewModels = isSearching ? filteredContactsViewModels : localContactsViewModels
    }
}

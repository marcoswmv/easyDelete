//
//  ContactStoreManager.swift
//  EasyDelete
//
//  Created by Marcos Vicente on 11.08.2021.
//

import UIKit
import Contacts
import Combine
import CoreData

enum ContactStoreError: Error {
    case permission(String)
    case commonError(Error)
}

protocol ContactsStoreProtocol: AnyObject {
    func fetchContacts(completionHandler: @escaping ContactsRequestCompletionBlock)
    func add(contact: ContactProtocol, completionHandler: @escaping ((ContactStoreError) -> Void))
    func delete(contactWith identifier: String, completionHandler: @escaping ((ContactStoreError) -> Void))
}

final class ContactsStore: ContactsStoreProtocol {
    
    private let store = CNContactStore()
    private let databaseManager: DatabaseManagerProtocol = DatabaseManager()
    private let queue = DispatchQueue(label: "ao.mwmv.EasyDelete.ContactStore")
    
    init() { }
    
    func fetchContacts(completionHandler: @escaping ContactsRequestCompletionBlock) {
        
        let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey,
                    CNContactImageDataKey, CNContactImageDataAvailableKey, CNContactIdentifierKey,
                    CNContactOrganizationNameKey, CNContactEmailAddressesKey, CNContactJobTitleKey]
        let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
        
        store.requestAccess(for: .contacts) { granted, error in
            if let error = error {
                completionHandler(.failure(.commonError(error)))
            }
            if granted {
                DispatchQueue.global().async {
                    do {
                        var contacts: [ContactModel] = [] 
                        try self.store.enumerateContacts(with: request, usingBlock: { (contact, _) in
                            let contact = ContactModel(contact: contact)
                            contacts.append(contact)
                        })
                        
                        completionHandler(.success(contacts))
                    } catch {
                        completionHandler(.failure(.commonError(error)))
                    }
                }
            } else {
                completionHandler(.failure(.permission(Consts.permissionError)))
            }
        }
    }
    
    func add(contact: ContactProtocol, completionHandler: @escaping ((ContactStoreError) -> Void)) {
        // Create a new contact
        let newContact = CNMutableContact(contact: contact)
        
        // Save the contact
        let saveRequest = CNSaveRequest()
        saveRequest.add(newContact, toContainerWithIdentifier: nil)
        if #available(iOS 15.4, *) {
            saveRequest.shouldRefetchContacts = true
        } else {
            // Fallback on earlier versions
        }
        
        queue.async { [weak self] in
            guard let `self` = self else { return }
            do {
                try self.store.execute(saveRequest)
            } catch {
                completionHandler(.commonError(error))
            }
        }
    }
    
    func delete(contactWith identifier: String, completionHandler: @escaping ((ContactStoreError) -> Void)) {
        guard !identifier.isEmpty else { print("[Debug - \(#function)]: Identifier is empty"); return }
        let predicate = CNContact.predicateForContacts(withIdentifiers: [identifier])
        let keys = [CNContactIdentifierKey]
        
        queue.async { [weak self] in
            guard let `self` = self else { return }
            do {
                let contacts = try self.store.unifiedContacts(matching: predicate, keysToFetch: keys as [CNKeyDescriptor])
                guard !contacts.isEmpty else { print("[Debug - \(#function)]: No contacts found"); return }
                guard let contact = contacts.first else { return }
                
                let request = CNSaveRequest()
                // swiftlint:disable:next force_cast
                let mutableContact = contact.mutableCopy() as! CNMutableContact
                
                request.delete(mutableContact)
                
                try self.store.execute(request)
            } catch let error {
                completionHandler(.commonError(error))
            }
        }
    }
}

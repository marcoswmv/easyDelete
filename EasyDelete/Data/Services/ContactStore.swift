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
    // TODO: Write more specific errors
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
        let request: CNContactFetchRequest = CNContactFetchRequest(keysToFetch: [CNContactVCardSerialization.descriptorForRequiredKeys()])
        
        store.requestAccess(for: .contacts) { granted, error in
            if let error = error {
                completionHandler(.failure(.commonError(error)))
            }
            if granted {
                DispatchQueue.global().async {
                    do {
                        var contacts: [CNContact] = []
                        
                        try self.store.enumerateContacts(with: request, usingBlock: { (contact, _) in
                            contacts.append(contact)
                        })
                        
                        self.exportContactsToFile(contacts) { result in
                            switch result {
                            case .success: break
                            case .failure(let error):
                                completionHandler(.failure(.commonError(error)))
                            }
                        }
                        let contactModels: [ContactModel] = contacts.map { ContactModel(contact: $0) } 
                        completionHandler(.success(contactModels))
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

//MARK: Helper methods
extension ContactsStore {
    private func exportContactsToFile(_ contacts: [CNContact], completionHandler: @escaping ((Result<Void, ContactStoreError>) -> Void)) {
        if let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = directoryURL.appendingPathComponent("EasyDeleteContacts").appendingPathExtension("vcf")
            
            do {
                let contactData = try CNContactVCardSerialization.data(with: contacts)
                
                do {
                    try contactData.write(to: fileURL, options: .atomic)
                    completionHandler(.success(()))
                } catch { 
                    completionHandler(.failure(.commonError(error)))
                }
                
            } catch {
                completionHandler(.failure(.commonError(error)))
            }
        }
    }
}

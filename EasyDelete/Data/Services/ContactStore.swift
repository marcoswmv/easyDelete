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
    case accessDenied(CNError)
    case commonError(Error)
}

enum ContactStoreSuccessfulAction: Error {
    case delete
    case add
}

protocol ContactsStoreProtocol: AnyObject {
    func fetchContacts(completionHandler: @escaping ContactsRequestCompletionBlock)
    func add(contacts: [ContactProtocol], completionHandler: @escaping CRUDContactsCompletionBlock)
    func delete(contacts: [ContactProtocol], completionHandler: @escaping CRUDContactsCompletionBlock)
}

final class ContactsStore: ContactsStoreProtocol {
    
    private let store = CNContactStore()
    private let queue = DispatchQueue(label: "ao.mwmv.EasyDelete.ContactStore")
    
    init() { }
    
    func fetchContacts(completionHandler: @escaping ContactsRequestCompletionBlock) {
        let request: CNContactFetchRequest = CNContactFetchRequest(keysToFetch: [CNContactVCardSerialization.descriptorForRequiredKeys()])
        
        store.requestAccess(for: .contacts) { [weak self] granted, error in
            guard let `self` = self else { return }
            if let error = error as? CNError {
                completionHandler(.failure(.accessDenied(error)))
            } else if granted {
                self.queue.async { [weak self] in
                    guard let `self` = self else { return }
                    do {
                        var contactModels: [ContactModel] = []
                        
                        try self.store.enumerateContacts(with: request, usingBlock: { (contact, _) in
                            let contactData = self.archiveContact(contact: contact) 
                            contactModels.append(ContactModel(contact: contact,
                                                              vCard: contactData))
                        })
                        
                        completionHandler(.success(contactModels))
                    } catch {
                        completionHandler(.failure(.commonError(error)))
                    }
                }
            }
        }
    }
    
    func add(contacts: [ContactProtocol], completionHandler: @escaping CRUDContactsCompletionBlock) {
        let saveRequest = CNSaveRequest()
        
        contacts.forEach { contact in
            guard let vCard = contact.vCard,
                  let unarchivedContact = unarchiveContact(data: vCard),
                  let mutableNewContact = unarchivedContact.mutableCopy() as? CNMutableContact else { return }
            
            saveRequest.add(mutableNewContact, toContainerWithIdentifier: nil)
        }
        
        executeRequest(saveRequest) { result in
            switch result {
            case .success:
                completionHandler(.success(.add))
            case .failure(let failure):
                completionHandler(.failure(failure))
            }
        }
    }
    
    func delete(contacts: [ContactProtocol], completionHandler: @escaping CRUDContactsCompletionBlock) {
        let deleteRequest = CNSaveRequest()
        
        contacts.forEach { contact in
            guard let vCard = contact.vCard,
                  let unarchivedContact = unarchiveContact(data: vCard),
                  let mutableContact = unarchivedContact.mutableCopy() as? CNMutableContact else { return }
            
            deleteRequest.delete(mutableContact)
        }
        
        executeRequest(deleteRequest) { result in
            switch result {
            case .success:
                completionHandler(.success(.delete))
            case .failure(let failure):
                completionHandler(.failure(failure))
            }
        }
    }
}

// MARK: Helper methods
extension ContactsStore {
    private func executeRequest(_ request: CNSaveRequest, _ completionHandler: @escaping ((Result<Bool, ContactStoreError>) -> Void)) {
        queue.async { [weak self] in
            guard let `self` = self else { return }
            do {
                try self.store.execute(request)
                completionHandler(.success(true))
            } catch {
                completionHandler(.failure(.commonError(error)))
            }
        }
    }
    
    public func archiveContact(contact: CNContact) -> Data? {
        return try? NSKeyedArchiver.archivedData(withRootObject: contact, requiringSecureCoding: false)
    }
    
    public func unarchiveContact(data: Data) -> CNContact? {
        return try? NSKeyedUnarchiver.unarchivedObject(ofClass: CNContact.self, from: data)
    }
}

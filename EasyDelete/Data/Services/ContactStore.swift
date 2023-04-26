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
    func delete(contact: ContactProtocol, completionHandler: @escaping ((ContactStoreError) -> Void))
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
                DispatchQueue.global().async { [weak self] in
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
            } else {
                completionHandler(.failure(.permission(Consts.permissionError)))
            }
        }
    }
    
    func add(contact: ContactProtocol, completionHandler: @escaping ((ContactStoreError) -> Void)) {
        guard let vCard = contact.vCard,
              let unarchivedContact = unarchiveContact(data: vCard),
              let mutableNewContact = unarchivedContact.mutableCopy() as? CNMutableContact else { return }
        
        let saveRequest = CNSaveRequest()
        saveRequest.add(mutableNewContact, toContainerWithIdentifier: nil)
        
        executeRequest(saveRequest, completionHandler)
    }
    
    func delete(contact: ContactProtocol, completionHandler: @escaping ((ContactStoreError) -> Void)) {
        guard let vCard = contact.vCard,
              let unarchivedContact = unarchiveContact(data: vCard),
              let mutableContact = unarchivedContact.mutableCopy() as? CNMutableContact else { return }
        
        let deleteRequest = CNSaveRequest()
        deleteRequest.delete(mutableContact)
        
        executeRequest(deleteRequest, completionHandler)
    }
}

// MARK: Helper methods
extension ContactsStore {
    private func executeRequest(_ request: CNSaveRequest, _ completionHandler: @escaping ((ContactStoreError) -> Void)) {
        queue.async { [weak self] in
            guard let `self` = self else { return }
            do {
                try self.store.execute(request)
            } catch {
                completionHandler(.commonError(error))
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

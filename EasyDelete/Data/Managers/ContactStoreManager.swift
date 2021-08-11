//
//  ContactStoreManager.swift
//  EasyDelete
//
//  Created by Marcos Vicente on 11.08.2021.
//

import Foundation
import Contacts
import Combine

class ContactStoreManager {
    
    static let shared = ContactStoreManager()
    
    private let store = CNContactStore()
    private let notificationCenter = NotificationCenter.default
    private let contactsRequestPublisher = PassthroughSubject<Contact, Error>()
    
    private init() {
        notificationCenter.addObserver(forName: .CNContactStoreDidChange, object: nil, queue: .main, using: { [weak self] (_) in
            guard let self = self else { return }
            self.requestContacts { [weak self] (result: Result<Contact, Error>) in
                guard let self = self else { return }
                switch result {
                case .success(let contact):
                    self.contactsRequestPublisher.send(contact)
                case .failure(let error):
                    self.contactsRequestPublisher.send(completion: Subscribers.Completion<Error>.failure(error))
                }
            }
        })
    }

    deinit {
        notificationCenter.removeObserver(self, name: .CNContactStoreDidChange, object: nil)
    }
    
    func commonDataSourceInit() {
        populateDataSource()
        requestContacts { [weak self] (result: Result<Contact, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let contact):
                self.contactsRequestPublisher.send(contact)
            case .failure(let error):
                self.contactsRequestPublisher.send(completion: Subscribers.Completion<Error>.failure(error))
            }
        }
    }
    
    private func requestContacts(completionHandler: @escaping EDTypes.ContactsRequestResult) {
        self.store.requestAccess(for: .contacts) { (granted, error) in
            
            if let errorToCatch = error {
                completionHandler(.failure(errorToCatch))
            } else if granted {
                print("[Contact Store] Request: Access granted")
                
                let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey,
                CNContactImageDataKey, CNContactImageDataAvailableKey,
                CNContactIdentifierKey, CNContactOrganizationNameKey, CNContactEmailAddressesKey]
                let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                
                do {
                    try self.store.enumerateContacts(with: request, usingBlock: { (contact, _) in
                        let contact = Contact(contact: contact)
                        completionHandler(.success(contact))
                    })
                } catch {
                    completionHandler(.failure(error))
                }
            } else {
                print("[Contact Store] Request: Access denied")
            }
        }
    }
    
    private func populateDataSource() {
        ContactStoreManager.shared.contactsRequestPublisher.sink { errorCompletion in
            switch errorCompletion {
            case .failure(let error):
                // To-do: Probably show it to the user
                print(error.localizedDescription)
            case .finished:
                break
            }
        } receiveValue: { contact in
            DataSourceManager.shared.contactArr.append(contact)
        }.store(in: &Consts.bag)
    }
}

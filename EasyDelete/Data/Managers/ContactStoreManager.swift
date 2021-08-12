//
//  ContactStoreManager.swift
//  EasyDelete
//
//  Created by Marcos Vicente on 11.08.2021.
//

import UIKit
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
                // [Contact Store] Request: Access granted"
                
                let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey,
                            CNContactImageDataKey, CNContactImageDataAvailableKey,
                            CNContactIdentifierKey, CNContactOrganizationNameKey, CNContactEmailAddressesKey, CNContactJobTitleKey]
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
                // "[Contact Store] Request: Access denied"
            }
        }
    }
    
    private func populateDataSource() {
        ContactStoreManager.shared.contactsRequestPublisher.sink { errorCompletion in
            switch errorCompletion {
            case .failure(let error):
                Alert.showErrorAlert(on: UIApplication.topViewController()!, message: error.localizedDescription)
            case .finished:
                break
            }
        } receiveValue: { contact in
            DataBaseManager.shared.update(with: contact)
        }.store(in: &Consts.bag)
    }
    
    func add(contact: Contact) {
        // Create a new contact
        let newContact = CNMutableContact()
        
        if let givenName = contact.givenName,
           let familyName = contact.familyName {
            newContact.givenName = givenName
            newContact.familyName = familyName
        }
        
        newContact.jobTitle = contact.jobTitle
        
        // Store the profile picture as data
        let image = UIImage(data: contact.thumbnailPhoto)
        newContact.imageData = image?.jpegData(compressionQuality: 1.0)
        
        for (label, phoneNumber) in zip(contact.phoneNumbersLabels, contact.phoneNumbers) {
            newContact.phoneNumbers.append(CNLabeledValue(
                                            label: label,
                                            value: CNPhoneNumber(stringValue: phoneNumber)))
        }
        
        for (label, email) in zip(contact.emailsLabels, contact.emails) {
            newContact.emailAddresses.append(CNLabeledValue(
                                                label: label,
                                                value: NSString(string: email)))
        }
        
        // Save the contact
        let saveRequest = CNSaveRequest()
        saveRequest.add(newContact, toContainerWithIdentifier: nil)
        
        do {
            try store.execute(saveRequest)
        } catch {
            Alert.showErrorAlert(on: UIApplication.topViewController()!, message: error.localizedDescription)
        }
    }
    
    func delete(contactWith identifier: String) {
        let predicate = CNContact.predicateForContacts(withIdentifiers: [identifier])
        let keys = [CNContactIdentifierKey]
        
        do {
            let contacts = try store.unifiedContacts(matching: predicate, keysToFetch: keys as [CNKeyDescriptor])
            guard !contacts.isEmpty else { print("[Contact Store - Delete] No contacts found"); return }
            guard let contact = contacts.first else { return }
            
            let request = CNSaveRequest()
            // swiftlint:disable:next force_cast
            let mutableContact = contact.mutableCopy() as! CNMutableContact
            
            request.delete(mutableContact)
            
            do {
                try store.execute(request)
            } catch let err {
                Alert.showErrorAlert(on: UIApplication.topViewController()!, message: err.localizedDescription)
            }
        } catch let error {
            Alert.showErrorAlert(on: UIApplication.topViewController()!, message: error.localizedDescription)
        }
    }
}

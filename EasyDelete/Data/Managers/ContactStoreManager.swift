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
    private let contactsRequestPublisher = PassthroughSubject<Contact, Error>()
    
    private init() { }
    
    func commonDataSourceInit() {
        populateDataSource()
        requestContacts()
    }
    
    private func populateDataSource() {
        ContactStoreManager.shared.contactsRequestPublisher
            .sink { completion in
                switch completion {
                case .failure(_):
                    DispatchQueue.main.async {
                        if let topViewController = UIApplication.topViewController() {
                            Alert.showSettingsAlert(on: topViewController)
                        }
                    }
                case .finished:
                    break
                }
            } receiveValue: { contact in
                DataBaseManager.shared.update(with: contact)
            }
            .store(in: &Consts.bag)
    }
    
    func requestContacts() {
        self.checkAuthorizationStatus { [unowned self] (result: EDTypes.ContactsRequestResult) in
            switch result {
            case .success(let contact):
                self.contactsRequestPublisher.send(contact)
            case .failure(let error):
                self.contactsRequestPublisher.send(completion: Subscribers.Completion<Error>.failure(error))
            }
        }
    }
    
    private func checkAuthorizationStatus(completionHandler: @escaping EDTypes.ContactsRequestResultHandler) {
        
        let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey,
                    CNContactImageDataKey, CNContactImageDataAvailableKey, CNContactIdentifierKey,
                    CNContactOrganizationNameKey, CNContactEmailAddressesKey, CNContactJobTitleKey]
        let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
        
        DispatchQueue.global().async { [unowned self] in
            
            store.requestAccess(for: .contacts) { granted, error in
                if let error = error {
                    completionHandler(.failure(error))
                } else {
                    if granted {
                        do {
                            try self.store.enumerateContacts(with: request, usingBlock: { (contact, _) in
                                let contact = Contact(contact: contact)
                                completionHandler(.success(contact))
                            })
                        } catch {
                            completionHandler(.failure(error))
                        }
                    }
                }
            }
        }
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
        
        DispatchQueue.global().async { [unowned self] in
            do {
                try self.store.execute(saveRequest)
            } catch {
                Alert.showErrorAlert(on: UIApplication.topViewController()!, message: error.localizedDescription)
            }
        }
    }
    
    func delete(contactWith identifier: String) {
        let predicate = CNContact.predicateForContacts(withIdentifiers: [identifier])
        let keys = [CNContactIdentifierKey]
        
        DispatchQueue.global().async { [unowned self] in
            do {
                let contacts = try self.store.unifiedContacts(matching: predicate, keysToFetch: keys as [CNKeyDescriptor])
                guard !contacts.isEmpty else { print("[Contact Store - Delete] No contacts found"); return }
                guard let contact = contacts.first else { return }
                
                let request = CNSaveRequest()
                // swiftlint:disable:next force_cast
                let mutableContact = contact.mutableCopy() as! CNMutableContact
                
                request.delete(mutableContact)
                
                try self.store.execute(request)
            } catch let error {
                Alert.showErrorAlert(on: UIApplication.topViewController()!, message: error.localizedDescription)
            }
        }
    }
}

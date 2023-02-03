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
    func delete(contactWith identifier: String)
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
    
    func add(contact: Contact) {
        // Create a new contact
        let newContact = CNMutableContact()
        
        if let givenName = contact.givenName,
           let familyName = contact.familyName {
            newContact.givenName = givenName
            newContact.familyName = familyName
        }
        
        // Store the profile picture as data
        if let thumbnailPhoto = contact.thumbnailPhoto {
            let image = UIImage(data: thumbnailPhoto)
            newContact.imageData = image?.jpegData(compressionQuality: 1.0)
        }
        
        if let phoneNumbers = contact.phoneNumbers {    
            for phoneNumber in phoneNumbers {
                newContact.phoneNumbers.append(CNLabeledValue(
                    label: "Mobile",
                    value: CNPhoneNumber(stringValue: phoneNumber)))
            }
        }
        
//        if let emailsLabels = contact.emailsLabels, let emails = contact.emails {    
//            for (label, email) in zip(emailsLabels, emails) {
//                newContact.emailAddresses.append(CNLabeledValue(
//                    label: label,
//                    value: NSString(string: email)))
//            }
//        }
        
        // Save the contact
        let saveRequest = CNSaveRequest()
        saveRequest.add(newContact, toContainerWithIdentifier: nil)
        
        queue.async { [weak self] in
            guard let `self` = self else { return }
            do {
                try self.store.execute(saveRequest)
            } catch {
                Alert.showErrorAlert(on: UIApplication.topViewController()!, message: error.localizedDescription)
            }
        }
    }
    
    func delete(contactWith identifier: String) {
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
                Alert.showErrorAlert(on: UIApplication.topViewController()!, message: error.localizedDescription)
            }
        }
    }
}

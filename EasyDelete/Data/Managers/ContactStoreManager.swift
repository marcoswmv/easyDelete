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
    
    private init() { }
    
    // MARK: - Store Request
    
    func populateDataSource() {
        self.checkAuthorizationStatus { (result: EDTypes.ContactsRequestResult) in
            switch result {
            case .success(let contact):
                DataBaseManager.shared.update(with: contact)
            case .failure(let error):
                DispatchQueue.main.async {
                    if let topViewController = UIApplication.topViewController() {
                        if error.errorCode == 100 {
                            Alert.showSettingsAlert(on: topViewController, with: error.title, message: error.reason)
                        } else {
                            Alert.showErrorAlert(on: topViewController, with: error.title, message: error.reason)
                        }
                    }
                }
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
                if error != nil {
                    let errorModel = retrieveErrorModel(error: error)
                    completionHandler(.failure(errorModel))
                } else {
                    if granted {
                        do {
                            try self.store.enumerateContacts(with: request, usingBlock: { (contact, _) in
                                let contact = Contact(contact: contact)
                                completionHandler(.success(contact))
                            })
                        } catch {
                            let errorModel = retrieveErrorModel(error: error)
                            completionHandler(.failure(errorModel))
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    private func retrieveErrorModel(error: Error?) -> ContactStoreErrorModel {
        guard let error = error as? CNError,
              let errorTitle = error.userInfo["NSLocalizedDescription"] as? String,
              let errorReason = error.userInfo["NSLocalizedFailureReason"] as? String else { return .mocked }
        
        return ContactStoreErrorModel(title: errorTitle, reason: errorReason, errorCode: error.errorCode)
    }
    
    // MARK: - CRUD Operations at Store
    
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

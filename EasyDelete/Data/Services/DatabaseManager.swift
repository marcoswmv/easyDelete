//
//  DatabaseManager.swift
//  EasyDelete
//
//  Created by Marcos Vicente on 01/02/23.
//

import UIKit
import CoreData

protocol DatabaseManagerProtocol: AnyObject {
    func retrieveContacts() throws -> [Contact]
    func create(contact: ContactProtocol)
    func delete(contact: Contact)
    func setAsDeleted(contact: Contact)
    func deleteAll()
}

final class DatabaseManager: DatabaseManagerProtocol {
    
    private let context: NSManagedObjectContext? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    let persistenStoreCoordinator = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.persistentStoreCoordinator
    
    func retrieveContacts() throws -> [Contact] {
        guard let context else { return [] }
        return try context.fetch(Contact.fetchRequest())
    }
    
    /// Creates a new object or updates it if already exists
    func create(contact: ContactProtocol) {
        guard let context else { return }
        
        do {
            let request: NSFetchRequest<Contact> = Contact.fetchRequest()
            request.predicate = NSPredicate(format: "identifier == %@", contact.identifier)
            let recordsCount = try context.count(for: request)
            
            if recordsCount == 0 {
                _ = Contact(contact: contact, insertInto: context)
                try context.save()
            } else {
                let records = try context.fetch(Contact.fetchRequest())
                let currentContact = records.first(where: { $0.identifier == contact.identifier })
                
                currentContact?.setValue(contact.givenName, forKey: "givenName")
                currentContact?.setValue(contact.familyName, forKey: "familyName")
                currentContact?.setValue(contact.jobTitle, forKey: "jobTitle")
                currentContact?.setValue(contact.organizationName, forKey: "organizationName")
                currentContact?.setValue(contact.thumbnailPhoto, forKey: "thumbnailPhoto")
                currentContact?.setValue(contact.phoneNumbers, forKey: "phoneNumbers")
                currentContact?.setValue(contact.emails, forKey: "emails")
                
                try context.save()
            }
        } catch {
            print("[Debug - \(#function)]: \(error.localizedDescription)")
        }
    }
    
    func delete(contact: Contact) {
        guard let context else { return }
        context.delete(contact)
        
        do {
            try context.save()
        } catch {
            print("[Debug - \(#function)]: \(error.localizedDescription)")
        }
    }
    
    /// Updating deletion related properties: isContactDeleted and deletionDate
    func setAsDeleted(contact: Contact) {
        guard let context else { return }
        contact.isContactDeleted = true
        contact.deletionDate = Date()
        
        do {
            try context.save()
        } catch {
            print("[Debug - \(#function)]: \(error.localizedDescription)")
        }
    }
    
    func deleteAll() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Contact")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try self.persistenStoreCoordinator?.execute(deleteRequest, with: context!)
        } catch {
            print("[Debug - \(#function)]: \(error.localizedDescription)")
        }
    }
}

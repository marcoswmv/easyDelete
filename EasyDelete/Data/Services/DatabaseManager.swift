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
    func setAsDeleted(contact: Contact, isDeleted: Bool)
    func deleteAll()
}

final class DatabaseManager: DatabaseManagerProtocol {
    
    private let context: NSManagedObjectContext? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    let persistenStoreCoordinator = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.persistentStoreCoordinator
    
    func retrieveContacts() throws -> [Contact] {
        guard let context else { return [] }
        return try context.fetch(Contact.fetchRequest())
    }
    
    /// Creates a new object if it's not existent
    func create(contact: ContactProtocol) {
        guard let context else { return }
        
        do {
            let request: NSFetchRequest<Contact> = Contact.fetchRequest()
            request.predicate = NSPredicate(format: "identifier == %@", contact.identifier)
            let numberOfRecords = try context.count(for: request)
            if numberOfRecords == 0 {
                let newContact = Contact(contact: contact, insertInto: context)
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
    
    /// Updating isDeleted status
    func setAsDeleted(contact: Contact, isDeleted: Bool = true) {
        guard let context else { return }
        contact.isContactDeleted = isDeleted
        
        do {
            try context.save()
        } catch {
            print("[Debug - \(#function)]: \(error.localizedDescription)")
        }
    }
    
    func update(contact: Contact, with newContact: Contact) {
        guard let context else { return }
//        var contact = contact
//        contact.givenName = newContact.givenName
        
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

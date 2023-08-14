//
//  ContactsPersistence.swift
//  EasyDelete
//
//  Created by Marcos Vicente on 06.08.2023.
//

import CoreData
import OSLog

class ContactsPersistence {
    
    // MARK: Logging
    
    let logger = Logger(subsystem: "ao.marwil.EasyDelete", category: "persistence")
    
    // MARK: - Core Data: SETUP
    
    /// A shared contacts persistence for use within the main app bundle.
    static let shared = ContactsPersistence()
    
    private let inMemory: Bool
    private var notificationToken: NSObjectProtocol?
    
    private var completionHandler: (() -> Void)?
    
    private init(inMemory: Bool = false) {
        self.inMemory = inMemory
        
        // Observe Core Data remote change notifications on the queue where the changes were made.
        notificationToken = NotificationCenter.default.addObserver(forName: .NSPersistentStoreRemoteChange, object: nil, queue: nil) { _ in
            self.logger.debug("Received a persistent store remote change notification.")
            self.fetchPersistentHistoryTransactionsAndChanges()
        }
    }
    
    deinit {
        if let observer = notificationToken {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    /// A peristent history token used for fetching transactions from the store.
    private var lastToken: NSPersistentHistoryToken?
    
    /// A persistent container to set up the Core Data stack.
    lazy var container: NSPersistentContainer = {
        /// - Tag: persistentContainer
        let container = NSPersistentContainer(name: "EasyDelete")
        
        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("Failed to retrieve a persistent store description.")
        }
        
        if inMemory {
            description.url = URL(fileURLWithPath: "/dev/null")
        }
        
        // Enable persistent store remote change notifications
        /// - Tag: persistentStoreRemoteChange
        description.setOption(true as NSNumber,
                              forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        // Enable persistent history tracking
        /// - Tag: persistentHistoryTracking
        description.setOption(true as NSNumber,
                              forKey: NSPersistentHistoryTrackingKey)
        
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        // This sample refreshes UI by consuming store changes via persistent history tracking.
        /// - Tag: viewContextMergeParentChanges
        container.viewContext.automaticallyMergesChangesFromParent = false
        container.viewContext.name = "viewContext"
        /// - Tag: viewContextMergePolicy
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.undoManager = nil
        container.viewContext.shouldDeleteInaccessibleFaults = true
        return container
    }()
    
    /// Creates and configures a private queue context.
    private func newTaskContext() -> NSManagedObjectContext {
        // Create a private queue context.
        /// - Tag: newBackgroundContext
        let taskContext = container.newBackgroundContext()
        taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        // Set unused undoManager to nil for macOS (it is nil by default on iOS)
        // to reduce resource requirements.
        taskContext.undoManager = nil
        return taskContext
    }
    
    // MARK: - OPERATIONS
    
    /// Gets all objects stored in Core Data
    func retrieveContacts() -> [Contact] {
        do {
            return try container.viewContext.fetch(Contact.fetchRequest())
        } catch {
            logger.debug("Error retrieving contacts from DB - \(error)")
        }
        return []
    }
    
    /// Uses `NSBatchInsertRequest` (BIR) to import objects into the Core Data store on a private queue.
    func importContacts(from contactModels: [ContactModel]) {
        logger.debug("Received \(contactModels.count) records.")
        
        // Import the Contacts into Core Data.
        logger.debug("Start importing data to the store...")
        guard !contactModels.isEmpty else { return }
        
        let taskContext = newTaskContext()
        // Add name and author to identify source of persistent history changes.
        taskContext.name = "importContext"
        taskContext.transactionAuthor = "importContacts"
        
        /// - Tag: performAndWait
        taskContext.perform {
            
            // Execute the batch insert.
            /// - Tag: batchInsertRequest
            let batchInsertRequest = self.newBatchInsertRequest(with: contactModels)
            if let fetchResult = try? taskContext.execute(batchInsertRequest),
               let batchInsertResult = fetchResult as? NSBatchInsertResult,
               let success = batchInsertResult.result as? Bool, success {
                return
            }
            self.logger.debug("Failed to execute batch insert request.")
        }
        
        logger.debug("Successfully inserted data.")
        logger.debug("Finished importing data.")
    }
    
    private func newBatchInsertRequest(with contactModels: [ContactModel]) -> NSBatchInsertRequest {
        var index = 0
        let total = contactModels.count
        
        // Provide one dictionary at a time when the closure is called.
        let batchInsertRequest = NSBatchInsertRequest(entity: Contact.entity(), managedObjectHandler: { (managedObject: NSManagedObject) -> Bool in
            guard index < total else { return true }
            
            if let contact = managedObject as? Contact {
                let data = contactModels[index]
                contact.identifier = data.identifier
                contact.givenName = data.givenName
                contact.familyName = data.familyName
                contact.thumbnailPhoto = data.thumbnailPhoto
                contact.isContactDeleted = data.isContactDeleted
                contact.phoneNumbers = data.phoneNumbers
                contact.deletionDate = data.deletionDate
                contact.emails = data.emails
                contact.organizationName = data.organizationName
                contact.jobTitle = data.jobTitle
                contact.vCard = data.vCard
            }
            
            index += 1
            return false
        })
        
        return batchInsertRequest
    }
    
    /// Synchronously deletes given records in the Core Data store with the specified object IDs.
    func deleteContacts(identifiedBy objectIDs: [NSManagedObjectID]) {
        let viewContext = container.viewContext
        logger.debug("Start deleting data from the store...")
        
        viewContext.perform {
            objectIDs.forEach { objectID in
                let contact = viewContext.object(with: objectID)
                viewContext.delete(contact)
            }
        }
        
        logger.debug("Successfully deleted data.")
    }
    
    /// Asynchronously deletes records in the Core Data store with the specified `Contact` managed objects.
    func deleteContacts(_ contacts: [Contact], shouldDeleteAll: Bool = false) {
        guard contacts.allSatisfy({ $0.isContactDeleted }) else { return }
        
        let objectIDs = contacts.map { $0.objectID }
        
        // Add name and author to identify source of persistent history changes.
        
        logger.debug("Start deleting data from the store...")
        
        let taskContext = newTaskContext()
        taskContext.name = "deleteContext"
        taskContext.transactionAuthor = "deleteContacts"
        
        taskContext.performAndWait {
            
            // Execute the batch delete.
            var batchDeleteRequest = NSBatchDeleteRequest(objectIDs: objectIDs)
            
            if shouldDeleteAll {
                let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Contact")
                batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            }
            guard let fetchResult = try? taskContext.execute(batchDeleteRequest),
                  let batchDeleteResult = fetchResult as? NSBatchDeleteResult,
                  let success = batchDeleteResult.result as? Bool, success
            else {
                self.logger.debug("Failed to execute batch delete request.")
                return
            }
        }
        
        logger.debug("Successfully deleted data.")
    }
    
    /// Updating deletion related properties: isContactDeleted and deletionDate
    func setIsDeleted(_ isDeleted: Bool, contacts: [Contact], completionHandler: @escaping (() -> Void)) {
        let taskContext = newTaskContext()
        taskContext.name = "updateContext"
        taskContext.transactionAuthor = "updateContacts"
        
        taskContext.performAndWait {
            let batchUpdateRequest = NSBatchUpdateRequest(entity: Contact.entity())
            let compoundPredicate = NSCompoundPredicate(
                type: .and,
                subpredicates: [
                    NSPredicate(format: "identifier IN %@", contacts.map { $0.identifier }),
                    NSPredicate(format: "isContactDeleted != %@", NSNumber(value: isDeleted))
                ]
            )
            
            batchUpdateRequest.predicate = compoundPredicate
            batchUpdateRequest.propertiesToUpdate = ["isContactDeleted": isDeleted, 
                                                     "deletionDate": Date()]
            
            guard let fetchResult = try? taskContext.execute(batchUpdateRequest),
                  let batchUpdateResult = fetchResult as? NSBatchUpdateResult,
                  let success = batchUpdateResult.result as? Bool, success
            else {
                self.logger.debug("Failed to execute batch update request.")
                return
            }
            
            self.completionHandler = completionHandler
            
            self.logger.debug("Successfully updated contacts.")
        }
    }
    
    // MARK: - UI Updates
    
    private func fetchPersistentHistoryTransactionsAndChanges() {
        let taskContext = newTaskContext()
        taskContext.name = "persistentHistoryContext"
        logger.debug("Start fetching persistent history changes from the store...")
        
        taskContext.performAndWait {
            // Execute the persistent history change since the last transaction.
            /// - Tag: fetchHistory
            let changeRequest = NSPersistentHistoryChangeRequest.fetchHistory(after: self.lastToken)
            if let historyResult = try? taskContext.execute(changeRequest) as? NSPersistentHistoryResult,
               let history = historyResult.result as? [NSPersistentHistoryTransaction],
               !history.isEmpty {
                self.mergePersistentHistoryChanges(from: history)
                return
            }
            
            self.logger.debug("No persistent history transactions found.")
        }
    }
    
    private func mergePersistentHistoryChanges(from history: [NSPersistentHistoryTransaction]) {
        logger.debug("Received \(history.count) persistent history transactions.")
        // Update view context with objectIDs from history change request.
        /// - Tag: mergeChanges
        let viewContext = container.viewContext
        viewContext.perform {
            for transaction in history {
                viewContext.mergeChanges(fromContextDidSave: transaction.objectIDNotification())
                self.lastToken = transaction.token
            }
            self.logger.debug("Finished merging history changes.")
            self.completionHandler?()
        }
    }
}

extension ContactsPersistence {
    func getContactsForContactIDs(_ contactIDs: [String]) -> [Contact] {
        return retrieveContacts().filter { persistedContact in
            return contactIDs.contains(where: { $0 == persistedContact.identifier })
        }
    }
}

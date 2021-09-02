//
//  DataBaseManager.swift
//  EasyDelete
//
//  Created by Marcos Vicente on 11.08.2021.
//

import Foundation
import Contacts
import RealmSwift
import Combine

class DataBaseManager {
    
    static let shared = DataBaseManager()
    
    private var token: NotificationToken?
    private let calendar = Calendar.current
    
    private init() { }
    
    /// This method is used to populate/update the database with data received from Contacts App service. That is add/Update contact objects in DB.
    /// The redeclaration of the realm is mandatory in this method, because it is going to accessed from another thread.
    func update(with contact: Contact) {
        let realm = try! Realm()
        try! realm.write({
            realm.add(contact, update: .modified)
        })
    }
    
    /// This method Reads all the data from database.
    func fetchContacts(deleted: Bool = false) -> EDTypes.DataBaseFetchRequest {
        let realm = try! Realm()
        let predicate = NSPredicate(format: "\(Keys.isDeleted) = %@", argumentArray: [deleted])
        return realm.objects(Contact.self).filter(predicate).sorted(byKeyPath: "\(Keys.givenName)", ascending: true)
    }
    
    /// This method is used to permanently Delete the contact from the database. And the contact is not restorable anymore.
    func delete(contacts: EDTypes.ContactsList) {
        let realm = try! Realm()
        try! realm.write {
            realm.delete(contacts)
        }
    }
    
    /// This method is used to set the contact as deleted.
    /// The contact is removed instantly from user's native "Contacts" App but it's stored in the database for later use (restoration).
    func setAsDeleted(contact: Contact) {
        let realm = try! Realm()
        let currentDay = Date()
        
        guard let scheduledDayForDeletion = calendar.date(byAdding: .day, value: 30, to: currentDay),
              let remainingDaysForDeletion = calendar.dateComponents([.day],
                                                                     from: currentDay,
                                                                     to: scheduledDayForDeletion).day else { return }
        // print("\nDay of deletion: \(currentDay) \nScheduled day for deletion: \(scheduledDayForDeletion) \nRemaining days for deletion: \(remainingDaysForDeletion)")
        try! realm.write {
            contact.setValue(true, forKey: Keys.isDeleted)
            contact.setValue(currentDay, forKey: Keys.dayOfDeletion)
            contact.setValue(scheduledDayForDeletion, forKey: Keys.scheduledDayForDeletion)
            contact.setValue(remainingDaysForDeletion, forKey: Keys.remainingDaysForDeletion)
        }
    }
    
    /// This method is going to update the days until deletion for a contact or delete it in case there are no days left
    func updateRemainingDaysForDeletion() {
        let realm = try! Realm()
        let currentDay = Date()
        let deletedContacts = fetchContacts(deleted: true)
        
        for contact in deletedContacts {
            if let scheduledDayForDeletion = contact.scheduledDayForDeletion,
               let remainingDaysForDeletion = calendar.dateComponents([.day],
                                                                      from: currentDay,
                                                                      to: scheduledDayForDeletion).day {
                
                // print("\nCurrent day: \(currentDay) \nScheduled day for deletion: \(scheduledDayForDeletion) \nRemaining days for deletion: \(remainingDaysForDeletion)")
                if remainingDaysForDeletion > 0 {
                    try! realm.write({
                        contact.setValue(remainingDaysForDeletion, forKey: Keys.remainingDaysForDeletion)
                    })
                } else {
                    try! realm.write {
                        realm.delete(contact)
                    }
                }
            }
        }
    }
}

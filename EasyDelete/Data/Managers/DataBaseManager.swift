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
    
    // swiftlint:disable:next force_try
    private let realm = try! Realm()
    // swiftlint:enable:next force_try
    
    private var token: NotificationToken?
    private let calendar = Calendar.current
    
    let dataChangePublisher = PassthroughSubject<Bool, Error>()
    
    private init() {
        token = realm.observe({ [weak self] (_, _) in
            guard let self = self else { return }
            self.dataChangePublisher.send(true)
        })
    }
    
    deinit {
        token?.invalidate()
    }
    
    /// This method is used to populate/update the database with data received from Contacts App service. That is add/Update contact objects in DB.
    /// The redeclaration of the realm is mandatory in this method, because it is going to accessed from another thread.
    func update(with contact: Contact) {
        try! realm.write({
            realm.add(contact, update: .modified)
        })
    }
    
    /// This method Reads all the data from database.
    func fetchContacts(deleted: Bool = false) -> Results<Contact> {
        let predicate = NSPredicate(format: "isDeleted = %@", argumentArray: [deleted])
        let result = realm.objects(Contact.self).filter(predicate).sorted(byKeyPath: "givenName", ascending: true)
        return result
    }
    
    /// This method is used to permanently Delete the contact from the database. And the contact is not restorable anymore.
    func delete(contacts: [Contact]) {
        try! realm.write {
            realm.delete(contacts)
        }
    }
    
    /// This method is used to set the contact as deleted.
    /// The contact is removed instantly from user's native "Contacts" App but it's stored in the database for later use (restoration).
    func setAsDeleted(contact: Contact) {
        //        let dayOfDeletion = Date()
        
        //        guard let scheduledDayOfDeletion = calendar.date(byAdding: .day, value: 30, to: dayOfDeletion),
        //              let daysLeftForDeletion = calendar.dateComponents([.day],
        //                                                                from: dayOfDeletion,
        //                                                                to: scheduledDayOfDeletion).day else { return }
        try! realm.write {
            contact.setValue(true, forKey: "isDeleted")
            //            contact.setValue(dayOfDeletion, forKey: "dayOfDeletion")
            //            contact.setValue(scheduledDayOfDeletion, forKey: "scheduledDayOfDeletion")
            //            contact.setValue(daysLeftForDeletion, forKey: "daysUntilDeletion")
        }
    }
    
    /// This method is going to update the days until deletion for a contact or delete it in case there are no days left
    //    func updateDaysUntilDeletion(for contact: Contact) {
    //        let currentDay = Date()
    //
    //        //        TO-DO: Problem with daysUntilDeletion. It's returning less days then it should. For ex: on first day of deletion it should show 30 but it's showing 29.
    //        guard let scheduledDayOfDeletion = contact.scheduledDayOfDeletion,
    //              let daysUntilDeletion = calendar.dateComponents([.day],
    //                                                              from: currentDay,
    //                                                              to: scheduledDayOfDeletion).day else { return }
    //
    //        if daysUntilDeletion > 0 {
    //            try! realm.write({
    //                realm.create(Contact.self, value: ["contactID": contact.identifier,
    //                                                   "daysUntilDeletion": daysUntilDeletion], update: .modified)
    //            })
    //        } else {
    //            try! realm.write {
    //                realm.delete(contact)
    //            }
    //        }
    //    }
}

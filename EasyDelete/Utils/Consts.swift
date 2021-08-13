//
//  Constants.swift
//  EasyDelete
//
//  Created by Marcos Vicente on 21.07.2021.
//

import UIKit

struct Consts {
    struct ContactsList {
        static let title = "Contacts"
        static let cell = "ContactCell"
        static let deleted = "Deleted"
        static let select = "Select"
        static let done = "Done"
    }
    
    struct DeletedContactsList {
        static let title = "Deleted Contacts"
        static let cell = "DeletedContactsList"
        static let manage = "Manage"
        static let delete = "Delete"
        static let select = "Select"
        static let done = "Done"
        static let recover = "Recover"
    }
    
    struct Alert {
        static let okButton = NSLocalizedString("Ok", comment: "Ok button - Ok")
        static let errorTitle = NSLocalizedString("An Error Occurred", comment: "Error alert title")
        static let noContactDeleteTitle = NSLocalizedString("No Contact To Delete", comment: "No contact to delete alert title")
        static let confirmationRequestTitle = NSLocalizedString("Are you sure?", comment: "Delete action sheet warning title")
        static let confirmationRequestMessage = NSLocalizedString("You won't be able to recover this(ese) contact(s).", comment: "Delete action sheet explanatory message")
        static let cancelButton = NSLocalizedString("Cancel", comment: "Deletion button - Cancel")
        static let confirmButton = NSLocalizedString("Confirm", comment: "Deletion button - Confirm")
    }
}

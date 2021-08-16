//
//  Constants.swift
//  EasyDelete
//
//  Created by Marcos Vicente on 21.07.2021.
//

import UIKit
import Combine

struct Consts {
    
    static var bag = Set<AnyCancellable>()
    
    static let phoneNumbersLabelPlaceholder = "Mobile"
    static let emailsLabelPlaceholder = "Email"
    
    struct ListScreen {
        static let done = "Done"
        static let select = "Select"
        static let noResults = "No Results"
    }
    
    struct ContactsList {
        static let title = "Contacts"
        static let cell = "ContactCell"
        static let deleted = "Deleted"
    }
    
    struct DeletedContactsList {
        static let title = "Deleted Contacts"
        static let cell = "DeletedContactsList"
        static let manage = "Manage"
        static let delete = "Delete"
        static let recover = "Recover"
        static let selectAll = "Select all"
        static let unselectAll = "Unselect all"
    }
    
    struct Alert {
        static let okButton = NSLocalizedString("Ok", comment: "Ok button - Ok")
        static let errorTitle = NSLocalizedString("An Error Occurred", comment: "Error alert title")
        static let selectContactsTitle = NSLocalizedString("Select a contact", comment: "Select a contact alert title")
        static let noContactsTitle = NSLocalizedString("No contacts to select", comment: "No contacts alert title")
        static let confirmationRequestTitle = NSLocalizedString("Are you sure?", comment: "Delete action sheet warning title")
        static let confirmationRequestMessage = NSLocalizedString("You won't be able to recover this(ese) contact(s).", comment: "Delete action sheet explanatory message")
        static let cancelButton = NSLocalizedString("Cancel", comment: "Deletion button - Cancel")
        static let confirmButton = NSLocalizedString("Confirm", comment: "Deletion button - Confirm")
    }
}

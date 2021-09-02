//
//  Constants.swift
//  EasyDelete
//
//  Created by Marcos Vicente on 21.07.2021.
//

import UIKit
import Combine

struct Keys {
    static let givenName = "givenName"
    static let isDeleted = "isDeleted"
    static let dayOfDeletion = "dayOfDeletion"
    static let scheduledDayForDeletion = "scheduledDayForDeletion"
    static let remainingDaysForDeletion = "remainingDaysForDeletion"
}

struct Consts {
    
    static var bag = Set<AnyCancellable>()
    
    static let contactPhotoPlaceholder = "person"
    static let phoneNumbersLabelPlaceholder = NSLocalizedString("Mobile", comment: "Mobile label placeholder")
    static let emailsLabelPlaceholder = NSLocalizedString("Email", comment: "Email label placeholder")
    static let contacts = NSLocalizedString("contacts", comment: "100 contacts - label")
    
    struct Numbers {
        static let dayInSeconds = 86400
    }
    
    struct ContactDetailView {
        static let title = NSLocalizedString("Contact", comment: "Contact detail modal screen - title")
        static let contactDetailsCell = "ContactDetailTableViewCell"
        static let numbersSection = NSLocalizedString("Phone numbers", comment: "Contact detail modal screen - Phone numbers section title")
        static let emailsSection = NSLocalizedString("Emails", comment: "Contact detail modal screen - Emails section title")
    }
    
    struct ListScreen {
        static let done = NSLocalizedString("Done", comment: "Generic list string item - Done")
        static let select = NSLocalizedString("Select", comment: "Generic list string item - Select")
        static let noResults = NSLocalizedString("No results", comment: "Generic list string item - No results")
    }
    
    struct ContactsList {
        static let title = NSLocalizedString("Contacts", comment: "Contacts list - title")
        static let cell = "ContactCell"
        static let deleted = NSLocalizedString("Deleted", comment: "Contacts list - Deleted button title")
        static let delete = NSLocalizedString("Delete", comment: "Contacts list - Delete button title")
    }
    
    struct DeletedContactsList {
        static let title = NSLocalizedString("Deleted Contacts", comment: "Deleted Contacts list - title")
        static let cell = "DeletedContactsList"
        static let manage = NSLocalizedString("Manage", comment: "Deleted contacts screen - Manage button title")
        static let delete = NSLocalizedString("Delete", comment: "Deleted contacts screen - Delete button title")
        static let recover = NSLocalizedString("Recover", comment: "Deleted contacts screen - Recover button title")
        static let selectAll = NSLocalizedString("Select all", comment: "Deleted contacts screen - Select all button title")
        static let unselectAll = NSLocalizedString("Unselect all", comment: "Deleted contacts screen - Unselect all button title")
        static let daysLeft = NSLocalizedString("days left", comment: "Deleted contacts screen - 100 days left - end of sentence")
    }
    
    struct Alert {
        static let okButton = NSLocalizedString("Ok", comment: "Ok button - title")
        static let errorTitle = NSLocalizedString("An Error Occurred", comment: "Error alert - title")
        static let selectContactsTitle = NSLocalizedString("Select a contact", comment: "Select a contact alert - title")
        static let noContactsTitle = NSLocalizedString("No contacts to select", comment: "No contacts alert - title")
        static let confirmationRequestTitle = NSLocalizedString("Are you sure?", comment: "Delete warning action sheet - title")
        static let confirmationRequestMessage = NSLocalizedString("You won't be able to recover this contact.", comment: "Delete warning action sheet - message")
        static let pluralConfirmationRequestMessage = NSLocalizedString("You won't be able to recover these contacts.", comment: "Delete warning action sheet - message")
        static let cancelButton = NSLocalizedString("Cancel", comment: "Deletion button - title")
        static let confirmButton = NSLocalizedString("Confirm", comment: "Deletion button - title")
    }
}

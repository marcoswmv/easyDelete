//
//  CNMutableContact+Extension.swift
//  EasyDelete
//
//  Created by Marcos Vicente on 03/02/23.
//

import UIKit
import Contacts

extension CNMutableContact {
    
    convenience init(contact: ContactProtocol) {
        self.init()
        if let givenName = contact.givenName,
           let familyName = contact.familyName {
            self.givenName = givenName
            self.familyName = familyName
        }
        
        if let jobTitle = contact.jobTitle {
            self.jobTitle = jobTitle
        }
        
        if let organizationName = contact.organizationName {
            self.organizationName = organizationName
        }
        
        // Store the profile picture as data
        if let thumbnailPhoto = contact.thumbnailPhoto {
            let image = UIImage(data: thumbnailPhoto)
            self.imageData = image?.jpegData(compressionQuality: 1.0)
        }
        
        for phoneNumber in contact.phoneNumbers {
            self.phoneNumbers.append(CNLabeledValue(label: "Mobile",
                                                    value: CNPhoneNumber(stringValue: phoneNumber)))
        }
        
        for email in contact.emails {
            self.emailAddresses.append(CNLabeledValue(label: "Personal",
                                                      value: NSString(string: email)))
            
        }
    }
}

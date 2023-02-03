//
//  PhoneNumbersDataSource.swift
//  EasyDelete
//
//  Created by Marcos Vicente on 17.08.2021.
//

import UIKit

//class ContactDetailsDataSource: BaseDataSource {
//    
//    private(set) var phoneNumbersData: ContactDetailsList = ContactDetailsList()
//    private(set) var emailsData: ContactDetailsList = ContactDetailsList()
//    
//    var contact: Contact?
//    
//    init(tableView: UITableView, contact: Contact) {
//        super.init(tableView: tableView)
//        self.contact = contact
//    }
//    
//    override func setup() {
//        super.setup()
//    }
//    
//    override func reload() {
////        if let contact = contact {
////            phoneNumbersData = DataSourceManager.shared.group(items: contact.phoneNumbers, with: contact.phoneNumbersLabels)
////        }
////        if let contact = contact {
////            emailsData = DataSourceManager.shared.group(items: contact.emails, with: contact.emailsLabels)
////        }
//    }
//    
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        2
//    }
//    
//    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        if section == 0 {
//            return phoneNumbersData.isEmpty ? "" : Consts.ContactDetailView.numbersSection
//        }
//        return emailsData.isEmpty ? "" : Consts.ContactDetailView.emailsSection
//    }
//    
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if section == 0 {
//            return phoneNumbersData.count
//        }
//        return emailsData.count
//    }
//    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = UITableViewCell(style: .value2, reuseIdentifier: Consts.ContactDetailView.contactDetailsCell)
//        
//            cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
//            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 15)
//        
//        if indexPath.section == 0 {
//            cell.textLabel?.text = phoneNumbersData[indexPath.row].label
//            cell.detailTextLabel?.text = phoneNumbersData[indexPath.row].item
//        } else {
//            cell.textLabel?.text = emailsData[indexPath.row].label.description
//            cell.detailTextLabel?.text = emailsData[indexPath.row].item
//        }
//        
//        return cell
//    }
//}


//
//  DeletedContactsDataSource.swift
//  EasyDelete
//
//  Created by Marcos Vicente on 07.08.2021.
//

import UIKit

class DeletedContactsDataSource: BaseDataSource {
    
    private(set) var data: EDTypes.ContactsList = EDTypes.ContactsList()
    private(set) var filteredData: EDTypes.ContactsList = EDTypes.ContactsList()
    private var isSearching: Bool = false
    
    override func setup() {
        super.setup()
    }
    
    override func reload() {
        let contactsFromDataBase = DataBaseManager.shared.fetchContacts(deleted: true)
        data = DataSourceManager.shared.getContactsArray(from: contactsFromDataBase)
        tableView.reloadData()
    }
    
    // MARK: - Data source
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            Alert.showActionSheetToAskForConfirmationToDelete(on: UIApplication.topViewController()!) { [weak self] confirmation in
                guard let self = self else { return }
                if confirmation {
                    self.deleteContact(at: indexPath)
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let recoverAction = UIContextualAction(style: .normal, title: Consts.DeletedContactsList.recover) { [weak self] (_, _, completionHandler) in
            guard let self = self else { return }
            self.recoverContact(at: indexPath)
            completionHandler(true)
        }
        recoverAction.backgroundColor = .link
        return UISwipeActionsConfiguration(actions: [recoverAction])
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        setTableViewDefaultStyle()
        if isSearching {
            if filteredData.isEmpty {
                addTableViewBackgroundView(with: "No Results")
                return 0
            }
            return filteredData.count
        } else if !data.isEmpty {
            return data.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Consts.DeletedContactsList.cell)!
        
        if isSearching {
            cell.textLabel?.attributedText = nameAttributedString(contact: filteredData[indexPath.row])
        } else {
            cell.textLabel?.attributedText = nameAttributedString(contact: data[indexPath.row])
        }
        return cell
    }
    
    // MARK: - Helpers
    func startQuery(with text: String) {
        isSearching = text.isEmpty ? false : true
        filteredData = data.filter { contact in
            guard let givenName = contact.givenName,
                  let familyName = contact.familyName else { return false }
            return givenName.lowercased().contains(text.lowercased()) || familyName.lowercased().contains(text.lowercased())
        }
        tableView.reloadData()
    }
    
    func deleteContact(at indexPath: IndexPath) {
        let contactToDelete = data[indexPath.row]
        DataBaseManager.shared.delete(contacts: [contactToDelete])
        reload()
    }
    
    func recoverContact(at indexPath: IndexPath) {
        if indexPath.isEmpty {
            Alert.showNoContactSelectedAlert(on: UIApplication.topViewController()!)
        } else {
            let contactToRecover = data[indexPath.row]
            ContactStoreManager.shared.add(contact: contactToRecover)
            DataBaseManager.shared.delete(contacts: [contactToRecover]) // Deleting to avoid duplicated contact with different ID's
            reload()
        }
    }
    
    func nameAttributedString(contact: Contact) -> NSMutableAttributedString {
        
        var attributedString = NSMutableAttributedString(string: "")
        
        if let givenName = contact.givenName {
            attributedString = NSMutableAttributedString(string: "\(givenName) ")
            let attributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17)]
            let boldString = NSMutableAttributedString(string: contact.familyName ?? "", attributes: attributes)
            
            attributedString.append(boldString)
        }
        return attributedString
    }
}

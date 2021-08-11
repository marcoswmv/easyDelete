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
//        data = DataSourceManager.shared.listContacts(DataSourceManager.shared.dummyContactData, deleted: true)
        tableView.reloadData()
    }
    
    // MARK: - Data source
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteContact(at: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let recoverAction = UIContextualAction(style: .normal, title: "Recover") { [weak self] (_, _, completionHandler) in
            guard let self = self else { return }
            self.recoverContact(at: indexPath)
            self.tableView.reloadData()
            completionHandler(true)
        }
        recoverAction.backgroundColor = .link
        return UISwipeActionsConfiguration(actions: [recoverAction])
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
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
        filteredData = data.filter { $0.givenName.lowercased().contains(text.lowercased()) || $0.familyName.lowercased().contains(text.lowercased()) }
        tableView.reloadData()
    }
    
    func deleteContact(at indexPath: IndexPath) {
        data.remove(at: indexPath.row) // tmp remove row
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.reloadData()
    }
    
    func recoverContact(at indexPath: IndexPath) {
        let contactToRecover = data[indexPath.row]
        contactToRecover.isDeleted = false
        DataSourceManager.shared.recover(contact: data[indexPath.row])
        data.removeAll { $0.contactId == contactToRecover.contactId } // tmp remove row
        tableView.reloadData()
    }
    
    func nameAttributedString(contact: Contact) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: "\(contact.givenName) ")
        let attributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17)]
        let boldString = NSMutableAttributedString(string: contact.familyName, attributes: attributes)
        
        attributedString.append(boldString)
        return attributedString
    }
}

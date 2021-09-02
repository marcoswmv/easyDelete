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
    
    var needsToFetchFromContactStore: Bool = false
    
    override func setup() {
        super.setup()
    }
    
    override func reload() {
        if needsToFetchFromContactStore {
            needsToFetchFromContactStore = false
            ContactStoreManager.shared.fetchContactsFromStore()
        }
        
        data = DataSourceManager.shared.getContactsListFromDataBase(deleted: true)
        isSearching = false
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.tableView.reloadData()
        }
        layoutTableViewFooter(with: String(data.count))
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
                    self.deleteContact(at: [indexPath])
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let recoverAction = UIContextualAction(style: .normal, title: Consts.DeletedContactsList.recover) { [weak self] (_, _, completionHandler) in
            guard let self = self else { return }
            self.recoverContact(at: indexPath)
            self.reload()
            completionHandler(true)
        }
        recoverAction.backgroundColor = .link
        return UISwipeActionsConfiguration(actions: [recoverAction])
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        setTableViewDefaultStyle()
        if isSearching {
            if filteredData.isEmpty {
                addTableViewBackgroundView(with: Consts.ListScreen.noResults)
                return 0
            }
            return filteredData.count
        } else if !data.isEmpty {
            return data.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: Consts.DeletedContactsList.cell)
        
        if #available(iOS 14.0, *) {
            var content = cell.defaultContentConfiguration()
            
            if isSearching {
                content.attributedText = DataSourceManager.shared.nameAttributedString(contact: filteredData[indexPath.row])
                content.secondaryText = "\(filteredData[indexPath.row].remainingDaysForDeletion.description) \(Consts.DeletedContactsList.daysLeft)"
                content.secondaryTextProperties.color = .gray
                content.secondaryTextProperties.font = UIFont.italicSystemFont(ofSize: 15)
            } else {
                content.attributedText = DataSourceManager.shared.nameAttributedString(contact: data[indexPath.row])
                content.secondaryText = "\(data[indexPath.row].remainingDaysForDeletion.description) \(Consts.DeletedContactsList.daysLeft)"
                content.secondaryTextProperties.color = .gray
                content.secondaryTextProperties.font = UIFont.italicSystemFont(ofSize: 15)
            }
            
            cell.contentConfiguration = content
        } else {
            if isSearching {
                cell.textLabel?.attributedText = DataSourceManager.shared.nameAttributedString(contact: filteredData[indexPath.row])
                cell.detailTextLabel?.text = "\(filteredData[indexPath.row].remainingDaysForDeletion.description) \(Consts.DeletedContactsList.daysLeft)"
                cell.detailTextLabel?.textColor = .gray
                cell.detailTextLabel?.font = UIFont.italicSystemFont(ofSize: 15)
            } else {
                cell.textLabel?.attributedText = DataSourceManager.shared.nameAttributedString(contact: data[indexPath.row])
                cell.detailTextLabel?.text = "\(data[indexPath.row].remainingDaysForDeletion.description) \(Consts.DeletedContactsList.daysLeft)"
                cell.detailTextLabel?.textColor = .gray
                cell.detailTextLabel?.font = UIFont.italicSystemFont(ofSize: 15)
            }
        }
        
        return cell
    }
    
    @objc func updateContactsRemainingDays() {
        DataBaseManager.shared.updateRemainingDaysForDeletion()
        reload()
    }
}
    
extension DeletedContactsDataSource: BaseDataSourceDelegate {
    
    func startQuery(with text: String) {
        isSearching = text.isEmpty ? false : true
        filteredData = data.filter { contact in
            guard let givenName = contact.givenName,
                  let familyName = contact.familyName else { return false }
            return givenName.lowercased().contains(text.lowercased()) || familyName.lowercased().contains(text.lowercased())
        }
        tableView.reloadData()
    }
    
    func deleteContact(at indexPaths: EDTypes.IndexPaths) {
        var contactsToDelete = EDTypes.ContactsList()
        
        for indexPath in indexPaths {
            let contact = data[indexPath.row]
            contactsToDelete.append(contact)
        }
        
        DataBaseManager.shared.delete(contacts: contactsToDelete)
        reload()
    }
    
    func recoverContact(at indexPath: IndexPath) {
        if indexPath.isEmpty {
            Alert.showNoContactSelectedAlert(on: UIApplication.topViewController()!)
        } else {
            let contactToRecover = data[indexPath.row]
            ContactStoreManager.shared.add(contact: contactToRecover)
            DataBaseManager.shared.delete(contacts: [contactToRecover]) // Deleting to avoid duplicated contact with different ID's
        }
    }
}

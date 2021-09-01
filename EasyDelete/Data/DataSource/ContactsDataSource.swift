//
//  ContactsDataSource.swift
//  EasyDelete
//
//  Created by Marcos Vicente on 04.08.2021.
//

import UIKit
import RealmSwift

class ContactsDataSource: BaseDataSource {
    
    private(set) var data: EDTypes.GroupedContacts = EDTypes.GroupedContacts()
    private(set) var filteredData: EDTypes.ContactsList = EDTypes.ContactsList()
    private var selectedCount: Int = 0
    var updateCountText: ((Int) -> Void)?
    var isSearching: Bool = false
    var token: NotificationToken?
    
    deinit {
        token?.invalidate()
    }
    
    override func setup() {
        super.setup()
        
        setDataBaseCollectionObserver()
    }
    
    override func reload() {
        let contactsFromDataBase = DataSourceManager.shared.getContactsListFromDataBase()
        data = DataSourceManager.shared.groupContactsBySections(contactsFromDataBase)
        isSearching = false
        tableView.reloadData()
    }
    
    func contactsCount() -> Int {
        return DataSourceManager.shared.getContactsListFromDataBase().count
    }
    
    func setDataBaseCollectionObserver() {
        let contactsFromDataBase = DataBaseManager.shared.fetchContacts()
        
        token = contactsFromDataBase.observe(keyPaths: [Keys.isDeleted], on: .main, { [weak self] changes in
            guard let self = self else { return }
            
            switch changes {
            case .initial:
                self.tableView.reloadData()
            case .update( _, let deletions, let insertions, let modifications):
                self.reload()
                
                print("Deletions: \(deletions)")
                print("Insertions: \(insertions)")
                print("Modifications: \(modifications)")
            case .error(let error):
                Alert.showErrorAlert(on: UIApplication.topViewController()!, message: error.localizedDescription)
            }
        })
    }
    
    // MARK: - Data source
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteContact(at: [indexPath])
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if isSearching {
            return 1
        } else if data.isEmpty {
            return 0
        }
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isSearching || data.isEmpty {
            return nil
        }
        return data[section].letter
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if isSearching || data.isEmpty {
            return nil
        }
        return data.map { $0.letter.uppercased() }
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
            return data[section].names.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Consts.ContactsList.cell)!
        
        if #available(iOS 14.0, *) {
            var content = cell.defaultContentConfiguration()
            
            if isSearching {
                content.attributedText = DataSourceManager.shared.nameAttributedString(contact: filteredData[indexPath.row])
            } else {
                content.attributedText = DataSourceManager.shared.nameAttributedString(contact: data[indexPath.section].names[indexPath.row])
            }
            
            cell.contentConfiguration = content
        } else {
            if isSearching {
                cell.textLabel?.attributedText = DataSourceManager.shared.nameAttributedString(contact: filteredData[indexPath.row])
            } else {
                cell.textLabel?.attributedText = DataSourceManager.shared.nameAttributedString(contact: data[indexPath.section].names[indexPath.row])
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !tableView.isEditing {
            let contact = data[indexPath.section].names[indexPath.row]
            let parentVC = UIApplication.topViewController()!
            let contactDetailVC = ContactDetailViewController(contact: contact)
            let navigationController = UINavigationController(rootViewController: contactDetailVC)
            parentVC.navigationController?.present(navigationController, animated: true, completion: nil)
            
            tableView.deselectRow(at: indexPath, animated: true)
        } else {
            selectedCount += 1
            updateCountText?(selectedCount)
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            selectedCount -= 1
            updateCountText?(selectedCount)
        }
    }
}

extension ContactsDataSource: BaseDataSourceDelegate {
    
    func startQuery(with text: String) {
        isSearching = text.isEmpty ? false : true
        filteredData = data
            .flatMap({ $0.names })
            .filter { contact in
                guard let givenName = contact.givenName,
                      let familyName = contact.familyName else { return false }
                return givenName.lowercased().contains(text.lowercased()) || familyName.lowercased().contains(text.lowercased())
            }
        tableView.reloadData()
    }
    
    func deleteContact(at indexPaths: EDTypes.IndexPaths) {
        var contactsToDelete = EDTypes.ContactsList()
        
        for indexPath in indexPaths {
            let contact = data[indexPath.section].names[indexPath.row]
            contactsToDelete.append(contact)
        }
        contactsToDelete.forEach { DataBaseManager.shared.setAsDeleted(contact: $0) }
        contactsToDelete.forEach { ContactStoreManager.shared.delete(contactWith: $0.identifier) }
        reload()
    }
    
    func recoverContact(at indexPath: IndexPath) { }
}

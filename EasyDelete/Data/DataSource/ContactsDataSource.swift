//
//  ContactsDataSource.swift
//  EasyDelete
//
//  Created by Marcos Vicente on 04.08.2021.
//

import UIKit

class ContactsDataSource: BaseDataSource {
    
    private(set) var data: EDTypes.GroupedContacts = EDTypes.GroupedContacts()
    private(set) var filteredData: EDTypes.ContactsList = EDTypes.ContactsList()
    private var isSearching: Bool = false
    
    override func setup() {
        super.setup()
        
        DataBaseManager.shared.dataChangePublisher.sink(receiveCompletion: { (_) in
            }, receiveValue: { [weak self] (detectedChanges) in
            // [Contacts Data Source] Data changed"
                guard let self = self else { return }
            if detectedChanges {
                self.reload()
            }
        }).store(in: &Consts.bag)
    }
    
    override func reload() {
        let contactsFromDataBase = DataBaseManager.shared.fetchContacts()
        data = DataSourceManager.shared.groupContactsBySections(contactsFromDataBase)
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
        
        if isSearching {
            cell.textLabel?.attributedText = nameAttributedString(contact: filteredData[indexPath.row])
        } else {
            cell.textLabel?.attributedText = nameAttributedString(contact: data[indexPath.section].names[indexPath.row])
        }
        return cell
    }
    
    // MARK: - Helpers
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
    
    func deleteContact(at indexPath: IndexPath) {
        let contactToDelete = data[indexPath.section].names[indexPath.row]
        
        ContactStoreManager.shared.delete(contactWith: contactToDelete.identifier)
        DataBaseManager.shared.setAsDeleted(contact: contactToDelete)
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

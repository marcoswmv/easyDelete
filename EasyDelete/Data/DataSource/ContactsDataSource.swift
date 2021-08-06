//
//  ContactsDataSource.swift
//  EasyDelete
//
//  Created by Marcos Vicente on 04.08.2021.
//

import UIKit

class ContactsDataSource: BaseDataSource {
    
    private(set) var data: Helpers.ContactSectionsType = Helpers.ContactSectionsType()
    private(set) var filteredData: [Contact] = [Contact]()
    private var isSearching: Bool = false
    
    override func setup() {
        super.setup()
    }
    
    override func reload() {
        let contacts: [Contact] = [
            Contact(givenName: "Marcos", familyName: "Vicente"),
            Contact(givenName: "Márcia", familyName: "Jeremias"),
            Contact(givenName: "Cássia", familyName: "Carmo"),
            Contact(givenName: "Walter", familyName: "Morgado"),
            Contact(givenName: "Danilson", familyName: "Pombal"),
            Contact(givenName: "Sidney", familyName: "Ribeiro")]
        
        data = Helpers.generateSections(from: contacts)
    }
    
    // MARK: - Data source
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteContact(tableView, at: indexPath)
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
        return data.map { $0.letter }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return filteredData.count
        } else if !data.isEmpty {
            return data[section].names.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.ContactsList.cell)!
        
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
            .filter { $0.givenName.lowercased().contains(text.lowercased()) || $0.familyName.lowercased().contains(text.lowercased()) }
        tableView.reloadData()
    }
    
    func deleteContact(_ tableView: UITableView, at indexPath: IndexPath) {
        if data[indexPath.section].names.count <= 1 {
                    data.remove(at: indexPath.section)
                    tableView.deleteSections(IndexSet(integer: indexPath.section), with: .left)
                } else {
                    data[indexPath.section].names.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .left)
                }
    }
    
    func nameAttributedString(contact: Contact) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: "\(contact.givenName) ")
        let boldString = NSMutableAttributedString(string: contact.familyName,
                                                   attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17)])

        attributedString.append(boldString)
        return attributedString
    }
}

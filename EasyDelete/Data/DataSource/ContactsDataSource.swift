//
//  ContactsDataSource.swift
//  EasyDelete
//
//  Created by Marcos Vicente on 04.08.2021.
//

import UIKit

class ContactsDataSource: BaseDataSource {
    
    private(set) var data: Helpers.ContactSectionsType = Helpers.ContactSectionsType()
    
    override func setup() {
        super.setup()
    }
    
    override func reload() {
        let contacts: [Contact] = [
            Contact(givenName: "Marcos", familyName: "Vicente"),
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
        return data.isEmpty ? 1 : data.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return data.isEmpty ? nil : data[section].letter
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return data.isEmpty ? nil : data.map { $0.letter }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.isEmpty ? 0 : data[section].names.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.ContactsList.cell)!
        let contactName = data[indexPath.section].names[indexPath.row]
        
        cell.textLabel?.text = "\(contactName.givenName) \(contactName.familyName)"
        
        return cell
    }
    
    // MARK: - Helpers
    
    func deleteContact(_ tableView: UITableView, at indexPath: IndexPath) {
        data[indexPath.section].names.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .left)
        
        if data[indexPath.section].names.isEmpty {
            data.remove(at: indexPath.section)
            tableView.reloadData()
        }
    }
}

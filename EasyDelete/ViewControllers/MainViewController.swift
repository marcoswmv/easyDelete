//
//  ViewController.swift
//  EasyDelete
//
//  Created by Marcos Vicente on 21.07.2021.
//

import UIKit

class MainViewController: UIViewController {
    
    typealias ContactSectionsType = [(letter: String, names: [String])]
    
    private var tableView: UITableView = UITableView()
    
    private var contacts: [String] = ["Marcos Vicente", "Cássia do Carmo", "Walter Morgado", "Danilson Pombal", "Sidney Ribeiro"]
    private var sections: ContactSectionsType = ContactSectionsType()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationBar()
        configureToolbar()
        configureTableView()
    }
    
    private func configureTableView() {
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.ContactsList.cell)
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.enableAutoLayout()
        tableView.setConstraints(to: view)
        
        populateData()
    }
    
    private func configureNavigationBar() {
        navigationItem.title = Constants.mainViewTitle
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Select", style: .done, target: self, action: #selector(handleSelect))
    }
    
    private func configureToolbar() {
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let deleteButton = UIBarButtonItem(title: "Delete", style: .done, target: self, action: #selector(handleDelete))
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(handleDone))
        
        if !(toolbarItems?.isEmpty ?? true) {
            toolbarItems?.removeAll()
        }

        toolbarItems = [deleteButton, flexibleSpace, doneButton]
    }
    
    private func populateData() {
        sections = Helpers.generateSections(from: contacts)
    }
    
    // MARK: - Handlers

    @objc private func handleSelect() {
        navigationItem.rightBarButtonItem?.isEnabled = false
        navigationController?.setToolbarHidden(false, animated: true)
        tableView.setEditing(true, animated: true)
    }
    
    @objc private func handleDelete() {
        if let indexPaths = tableView.indexPathsForSelectedRows {
            for indexPath in indexPaths.reversed() {
                self.deleteContact(tableView, at: indexPath)
            }
        }
        
        navigationItem.rightBarButtonItem?.isEnabled = true
        navigationController?.setToolbarHidden(true, animated: true)
        tableView.setEditing(false, animated: true)
        
    }
    
    @objc private func handleDone() {
        navigationItem.rightBarButtonItem?.isEnabled = true
        navigationController?.setToolbarHidden(true, animated: true)
        tableView.setEditing(false, animated: true)
        
    }
}

extension MainViewController: UITableViewDataSource, UITableViewDelegate {

    // MARK: - Data source
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.deleteContact(tableView, at: indexPath)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.isEmpty ? 1 : sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections.isEmpty ? nil : sections[section].letter
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sections.isEmpty ? nil : sections.map { $0.letter }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections.isEmpty ? 0 : sections[section].names.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.ContactsList.cell)!
        let contactName = sections[indexPath.section].names[indexPath.row]
        
        cell.textLabel?.text = contactName
        
        return cell
    }
    
    // MARK: - Helpers
    
    func deleteContact(_ tableView: UITableView, at indexPath: IndexPath) {
        sections[indexPath.section].names.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        
        if sections[indexPath.section].names.isEmpty {
            sections.remove(at: indexPath.section)
            tableView.reloadData()
        }
    }
}

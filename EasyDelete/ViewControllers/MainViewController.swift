//
//  ViewController.swift
//  EasyDelete
//
//  Created by Marcos Vicente on 21.07.2021.
//

import UIKit

class MainViewController: UIViewController {
    
    private var tableView: UITableView = UITableView()
    
    private var contacts: [String] = ["Marcos Vicente", "Cássia do Carmo", "Walter Morgado", "Danilson Pombal", "Sidney Ribeiro"]
    private var sections: [(letter: String, names: [String])] = [(letter: String, names: [String])]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationBar()
        configureTableView()
    }
    
    private func configureTableView() {
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.ContactsList.cell)
        tableView.enableAutoLayout()
        tableView.setConstraints(to: view)
        
        populateData()
    }
    
    private func configureNavigationBar() {
        navigationItem.title = Constants.mainViewTitle
        navigationController?.navigationBar.prefersLargeTitles = true
        
    }
    
    private func populateData() {
        sections = Helpers.generateSections(from: contacts)
    }
}

// MARK: - Data source

extension MainViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            sections[indexPath.section].names.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            print("Row was deleted")
            
            if sections[indexPath.section].names.isEmpty {
                sections.remove(at: indexPath.section)
                tableView.reloadData()
                print("Section was deleted")
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].letter
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sections.map { $0.letter }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].names.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.ContactsList.cell)!
        let contactName = sections[indexPath.section].names[indexPath.row]
        
        cell.textLabel?.text = contactName
        
        return cell
    }
}

// MARK: - Delegate

extension MainViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

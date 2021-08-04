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
        
        navigationItem.title = Constants.mainViewTitle
        navigationController?.navigationBar.prefersLargeTitles = true
        
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
    
    private func populateData() {
        sections = Helpers.generateSections(from: contacts)
    }
}

// MARK: - Data source

extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    
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

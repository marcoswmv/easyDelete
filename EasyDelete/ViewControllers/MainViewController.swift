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
    }
}

extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.ContactsList.cell)!
        let contactName = contacts[indexPath.row]
        
        cell.textLabel?.text = contactName
        
        return cell
    }
}

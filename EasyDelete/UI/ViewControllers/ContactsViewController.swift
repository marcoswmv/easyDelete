//
//  ViewController.swift
//  EasyDelete
//
//  Created by Marcos Vicente on 21.07.2021.
//

import UIKit

class ContactsViewController: UIViewController {
    
    private var tableView: UITableView = UITableView()
    
    var dataSource: ContactsDataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDataSource()
        configureTableView()
        configureNavigationBar()
        configureToolbar()
    }
    
    private func setupDataSource() {
        dataSource = ContactsDataSource(tableView: tableView)
        dataSource?.reload()
    }
    
    private func configureTableView() {
        view.addSubview(tableView)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.ContactsList.cell)
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.enableAutoLayout()
        tableView.setConstraints(to: view)
    }
    
    private func configureNavigationBar() {
        navigationItem.title = Constants.mainViewTitle
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Select", style: .done, target: self, action: #selector(handleSelect))
    }
    
    private func configureToolbar() {
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let deleteButton = UIBarButtonItem(title: "Delete", style: .done, target: self, action: #selector(handleDelete))
        deleteButton.tintColor = .red
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(handleDone))
        
        toolbarItems = [deleteButton, flexibleSpace, doneButton]
    }
    
    private func enableEditingMode(enable: Bool) {
        navigationItem.rightBarButtonItem?.isEnabled = enable
        navigationController?.setToolbarHidden(enable, animated: true)
        tableView.setEditing(!enable, animated: enable)
    }
    
    // MARK: - Handlers

    @objc private func handleSelect() {
        enableEditingMode(enable: false)
    }
    
    @objc private func handleDelete() {
        if let indexPaths = tableView.indexPathsForSelectedRows {
            for indexPath in indexPaths.reversed() {
                dataSource?.deleteContact(tableView, at: indexPath)
            }
        }
        enableEditingMode(enable: true)
    }
    
    @objc private func handleDone() {
        enableEditingMode(enable: true)
    }
}

//
//  ViewController.swift
//  EasyDelete
//
//  Created by Marcos Vicente on 21.07.2021.
//

import UIKit

class ContactsViewController: UIViewController {
    
    private var tableView: UITableView = UITableView()
    private let searchController: UISearchController = UISearchController(searchResultsController: nil)
    
    var dataSource: ContactsDataSource?
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDataSource()
        configureTableView()
        configureNavigationBar()
        configureToolbar()
        configureSearchBarController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        dataSource?.reload()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        editingMode(disable: true)
    }
    
    private func setupDataSource() {
        dataSource = ContactsDataSource(tableView: tableView)
        dataSource?.reload()
    }
    
    private func configureTableView() {
        view.addSubview(tableView)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Consts.ContactsList.cell)
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.enableAutoLayout()
        tableView.setConstraints(to: view)
    }
    
    fileprivate func configureNavigationBar() {
        navigationItem.title = Consts.ContactsList.title
        navigationController?.navigationBar.prefersLargeTitles = true
        let leftNavBarButton = UIBarButtonItem(title: Consts.ContactsList.deleted, style: .done, target: self, action: #selector(handlePushDeleted))
        let rightNavBarButton = UIBarButtonItem(title: Consts.ContactsList.select, style: .done, target: self, action: #selector(handleSelect))
        navigationItem.leftBarButtonItem = leftNavBarButton
        navigationItem.rightBarButtonItem = rightNavBarButton
    }
    
    fileprivate func configureToolbar() {
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let deleteButton = UIBarButtonItem(title: Consts.ContactsList.deleted, style: .done, target: self, action: #selector(handleDelete))
        deleteButton.tintColor = .red
        let doneButton = UIBarButtonItem(title: Consts.ContactsList.done, style: .done, target: self, action: #selector(handleDone))
        
        toolbarItems = [deleteButton, flexibleSpace, doneButton]
    }
    
    fileprivate func configureSearchBarController() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        self.definesPresentationContext = true
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
    }
    
    fileprivate func editingMode(disable: Bool) {
        navigationItem.rightBarButtonItem?.isEnabled = disable
        navigationController?.setToolbarHidden(disable, animated: true)
        tableView.setEditing(!disable, animated: disable)
    }
    
    // MARK: - Handlers

    @objc private func handleSelect() {
        editingMode(disable: false)
    }
    
    @objc private func handleDelete() {
        if let indexPaths = tableView.indexPathsForSelectedRows {
            let sortedIndexPaths = DataSourceManager.shared.sortIndexPathsInDescendingOrder(indexPaths)
            for indexPath in sortedIndexPaths {
                dataSource?.deleteContact(at: indexPath)
            }
        }
    }
    
    @objc private func handleDone() {
        editingMode(disable: true)
    }
    
    @objc private func handlePushDeleted() {
        let deletedContactsVC = DeletedContactsViewController()
        navigationController?.pushViewController(deletedContactsVC, animated: true)
    }
}

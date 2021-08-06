//
//  DeletedContactsViewController.swift
//  EasyDelete
//
//  Created by Marcos Vicente on 06.08.2021.
//

import UIKit

class DeletedContactsViewController: UIViewController {
    
    private var tableView: UITableView = UITableView()
    private let searchController: UISearchController = UISearchController(searchResultsController: nil)
    
    var dataSource: DeletedContactsDataSource?
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDataSource()
        configureTableView()
        configureNavigationBar()
        configureToolbar()
        configureSearchBarController()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        manageDeletedContacts(enable: false)
    }
    
    private func setupDataSource() {
        dataSource = DeletedContactsDataSource(tableView: tableView)
        dataSource?.reload()
    }
    
    fileprivate func configureTableView() {
        view.addSubview(tableView)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Consts.DeletedContactsList.cell)
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.enableAutoLayout()
        tableView.setConstraints(to: view)
    }
    
    fileprivate func configureNavigationBar() {
        navigationItem.title = Consts.DeletedContactsList.title
        navigationController?.navigationBar.prefersLargeTitles = true
        let rightNavBarButton = UIBarButtonItem(title: Consts.DeletedContactsList.manage, style: .done, target: self, action: #selector(handleManage))
        navigationItem.rightBarButtonItem = rightNavBarButton
    }
    
    fileprivate func configureToolbar() {
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let deleteButton = UIBarButtonItem(title: Consts.DeletedContactsList.delete, style: .done, target: self, action: #selector(handleDelete))
        deleteButton.tintColor = .red
        let doneButton = UIBarButtonItem(title: Consts.DeletedContactsList.done, style: .done, target: self, action: #selector(handleDone))
        
        toolbarItems = [deleteButton, flexibleSpace, doneButton]
    }
    
    fileprivate func configureSearchBarController() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        self.definesPresentationContext = true
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
    }
    
    fileprivate func manageDeletedContacts(enable: Bool) {
        navigationItem.rightBarButtonItem?.isEnabled = !enable
        navigationController?.setToolbarHidden(!enable, animated: true)
        tableView.setEditing(enable, animated: enable)
    }
    
    // MARK: - Handlers
    @objc private func handleManage() {
        manageDeletedContacts(enable: true)
    }
    
    @objc private func handleDelete() {
        Alert.showActionSheetToAskForConfirmationToDelete(on: self) { [weak self] confirmation in
            guard let self = self else { return }
            if confirmation {
                if let indexPaths = self.tableView.indexPathsForSelectedRows {
                    for indexPath in indexPaths.sorted(by: { $0.section > $1.section }) {
        //                dataSource?.deleteContact(tableView, at: indexPath)
                    }
                }
            }
        }
    }
    
    @objc private func handleDone() {
        manageDeletedContacts(enable: false)
    }
}
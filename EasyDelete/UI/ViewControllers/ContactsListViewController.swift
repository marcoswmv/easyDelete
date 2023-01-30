//
//  ContactsListViewController.swift
//  EasyDelete
//
//  Created by Marcos Vicente on 21.07.2021.
//

import UIKit

final class ContactsListViewController: UIViewController {
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.allowsMultipleSelectionDuringEditing = true

        return tableView
    }()

    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false

        return searchController
    }()

    private lazy var refreshControl: UIRefreshControl = {
        UIRefreshControl()
    }()

    lazy var tableViewTapRecognizer: UITapGestureRecognizer = {
        UITapGestureRecognizer()
    }()
    
//    var dataSource: ContactsDataSource?
//    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupDataSource()

//        dataSource?.updateCountText = { [weak self] count in
//            guard let self = self else { return }
//            // swiftlint:disable:next empty_count
//            if count > 0 {
//                self.navigationItem.title = "Selected \(count) contact\(count >= 2 ? "s" : "")"
//            } else {
//                self.navigationItem.title = Consts.ContactsList.title
//            }
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        dataSource?.reload()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        editingMode(disable: true)
    }
    
    private func setupUI() {
        setupNavigationBar()
        setupTableView()
        setupToolbar()
        searchController.searchBar.delegate = self
    }
    
    private func setupDataSource() {
//        dataSource = ContactsDataSource(tableView: tableView)
//        dataSource?.reload()
    }

    private func setupNavigationBar() {
        navigationItem.title = Consts.ContactsList.title
        navigationController?.navigationBar.prefersLargeTitles = true

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true

        let leftNavBarButton = UIBarButtonItem(title: Consts.ContactsList.deleted, style: .plain, target: self, action: #selector(handlePushDeleted))
        let rightNavBarButton = UIBarButtonItem(title: Consts.ListScreen.select, style: .plain, target: self, action: #selector(handleSelect))
        navigationItem.leftBarButtonItem = leftNavBarButton
        navigationItem.rightBarButtonItem = rightNavBarButton
    }
    
    private func setupTableView() {
        view.addSubview(tableView)

        tableView.enableAutoLayout()
        tableView.setConstraints(to: view)

        tableView.refreshControl = self.refreshControl
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Consts.ContactsList.cell)

        tableViewTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapOnTable))
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
    }
    
    private func setupToolbar() {
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let deleteButton = UIBarButtonItem(title: Consts.ContactsList.delete, style: .plain, target: self, action: #selector(handleDelete))
        deleteButton.tintColor = .red
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(handleDone))
        
        toolbarItems = [deleteButton, flexibleSpace, doneButton]
    }
    
    func editingMode(disable: Bool) {
        if disable {
            self.navigationItem.title = Consts.ContactsList.title
        }
        navigationItem.leftBarButtonItem?.isEnabled = disable
        navigationItem.rightBarButtonItem?.isEnabled = disable
        navigationController?.setToolbarHidden(disable, animated: true)
        searchController.searchBar.endEditing(true)
        tableView.setEditing(!disable, animated: disable)
        tableView.removeGestureRecognizer(tableViewTapRecognizer)
    }
    
    // MARK: - Handlers

    @objc private func handleSelect() {
        editingMode(disable: false)
    }
    
    @objc private func handleDelete() {
//        if let indexPaths = tableView.indexPathsForSelectedRows {
//            let sortedIndexPaths = DataSourceManager.shared.sortIndexPathsInDescendingOrder(indexPaths)
//            var indexPathsToDelete = EDTypes.IndexPaths()
//            
//            for indexPath in sortedIndexPaths {
//                indexPathsToDelete.append(indexPath)
//            }
//            dataSource?.deleteContact(at: indexPathsToDelete)
//        } else {
//            Alert.showNoContactSelectedAlert(on: UIApplication.topViewController()!)
//        }
    }
    
    @objc private func handleDone() {
        editingMode(disable: true)
    }
    
    @objc private func handlePushDeleted() {
        let deletedContactsVC = DeletedContactsViewController()
        navigationController?.pushViewController(deletedContactsVC, animated: true)
    }
    
    @objc private func handleRefresh() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
//            if self.dataSource?.isSearching == false {
//                self.dataSource?.reload()
//                self.refreshControl.endRefreshing()
//            }
        }
    }
    
    @objc private func handleTapOnTable() {
        print("Tapping table view")
    }
}

//
//  ContactsListViewController.swift
//  EasyDelete
//
//  Created by Marcos Vicente on 21.07.2021.
//

import UIKit
import SnapKit

final class ContactsListViewControllerOld: UITableViewController {
    
    // MARK: - Lifecycle
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI()
//    }
//    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        
//        editingMode(disable: true)
//    }
//    
//    private func setupUI() {
//        setupNavigationBar()
//        setupTableView()
//        setupToolbar()
//        searchController.searchBar.delegate = self
//    }
//
//    private func setupNavigationBar() {
//        navigationItem.title = Consts.ContactsList.title
//        navigationController?.navigationBar.prefersLargeTitles = true
//
//        navigationItem.searchController = searchController
//        navigationItem.hidesSearchBarWhenScrolling = false
//        definesPresentationContext = true
//
//        let leftNavBarButton = UIBarButtonItem(title: Consts.ContactsList.deleted, style: .plain, target: self, action: #selector(handlePushDeleted))
//        let rightNavBarButton = UIBarButtonItem(title: Consts.ListScreen.select, style: .plain, target: self, action: #selector(handleSelect))
//        navigationItem.leftBarButtonItem = leftNavBarButton
//        navigationItem.rightBarButtonItem = rightNavBarButton
//    }
//    
//    private func setupTableView() {
//        view.addSubview(tableView)
//
//        tableView.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
//        }
//
//        tableView.refreshControl = self.refreshControl
//        tableView.register(ContactTableViewCell.self, forCellReuseIdentifier: ContactTableViewCell.identifier)
//    }
//    
//    private func setupToolbar() {
//        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
//        let deleteButton = UIBarButtonItem(title: Consts.ContactsList.delete, style: .plain, target: self, action: #selector(handleDelete))
//        deleteButton.tintColor = .red
//        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(handleDone))
//        
//        toolbarItems = [deleteButton, flexibleSpace, doneButton]
//    }
//    
//    func editingMode(disable: Bool) {
//        if disable {
//            self.navigationItem.title = Consts.ContactsList.title
//        }
//        navigationItem.leftBarButtonItem?.isEnabled = disable
//        navigationItem.rightBarButtonItem?.isEnabled = disable
//        navigationController?.setToolbarHidden(disable, animated: true)
//        searchController.searchBar.endEditing(true)
//        tableView.setEditing(!disable, animated: disable)
//        tableView.removeGestureRecognizer(tableViewTapRecognizer)
//    }
//    
//    // MARK: - Handlers
//
//    @objc private func handleSelect() {
//        editingMode(disable: false)
//    }
//    
//    @objc private func handleDelete() {
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
//    }
//    
//    @objc private func handleDone() {
//        editingMode(disable: true)
//    }
//    
//    @objc private func handlePushDeleted() {
//        let deletedContactsVC = DeletedContactsViewController()
//        navigationController?.pushViewController(deletedContactsVC, animated: true)
//    }
//    
//    @objc private func handleRefresh() {
//        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
//            if self.dataSource?.isSearching == false {
//                self.dataSource?.reload()
//                self.refreshControl.endRefreshing()
//            }
//        }
//    }
}

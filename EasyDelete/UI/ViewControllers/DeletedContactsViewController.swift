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
    private let refreshControl: UIRefreshControl = UIRefreshControl()
    
    var dataSource: DeletedContactsDataSource?
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDataSource()
        configureUIEssentials()
        continuouslyUpdateDeletedContactsRemainingTime()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        manageDeletedContacts(enable: false)
    }
    
    fileprivate func configureUIEssentials() {
        configureTableView()
        configureNavigationBar()
        configureToolbar()
        configureSearchBarController()
        configureRefreshControl()
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
        let buttonTitle = Consts.DeletedContactsList.manage
        let rightNavBarButton = UIBarButtonItem(title: buttonTitle, style: .plain, target: self, action: #selector(handleManage))
        navigationItem.rightBarButtonItem = rightNavBarButton
    }
    
    fileprivate func configureToolbar() {
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let deleteButton = UIBarButtonItem(title: Consts.DeletedContactsList.delete, style: .plain, target: self, action: #selector(handleDelete))
        deleteButton.tintColor = .red
        let doneButton = UIBarButtonItem(title: Consts.ListScreen.done, style: .plain, target: self, action: #selector(handleDone))
        let recoverButton = UIBarButtonItem(title: Consts.DeletedContactsList.recover, style: .plain, target: self, action: #selector(handleRecover))
        
        toolbarItems = [deleteButton, flexibleSpace, recoverButton, flexibleSpace, doneButton]
    }
    
    fileprivate func configureSearchBarController() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        self.definesPresentationContext = true
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
    }
    
    fileprivate func configureRefreshControl() {
        tableView.refreshControl = self.refreshControl
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
    }
    
    fileprivate func manageDeletedContacts(enable: Bool) {
        navigationItem.rightBarButtonItem?.isEnabled = !enable
        navigationController?.setToolbarHidden(!enable, animated: true)
        tableView.setEditing(enable, animated: enable)
    }
    
    fileprivate func continuouslyUpdateDeletedContactsRemainingTime() {
        let dayInSeconds = TimeInterval(86400)
        let target = dataSource ?? DeletedContactsDataSource(tableView: tableView)
        let selector = #selector(dataSource?.updateContactsRemainingDays)
        Timer.scheduledTimer(timeInterval: dayInSeconds, target: target, selector: selector, userInfo: nil, repeats: true)
    }
    
    // MARK: - Handlers
    
    @objc private func handleManage() {
        manageDeletedContacts(enable: true)
    }
    
    @objc private func handleDelete() {
        if let indexPaths = self.tableView.indexPathsForSelectedRows {
            Alert.showActionSheetToAskForConfirmationToDelete(on: self) { [weak self] confirmation in
                guard let self = self else { return }
                if confirmation {
                    let sortedIndexPaths = DataSourceManager.shared.sortIndexPathsInDescendingOrder(indexPaths)
                    for indexPath in sortedIndexPaths {
                        self.dataSource?.deleteContact(at: indexPath)
                    }
                }
            }
        } else {
            if (dataSource?.data.isEmpty) != nil {
                Alert.showNoContactsAlert(on: self)
            } else {
                Alert.showNoContactSelectedAlert(on: self)
            }
        }
    }
    
    @objc private func handleDone() {
        manageDeletedContacts(enable: false)
    }
    
    @objc private func handleRecover() {
        if let indexPaths = self.tableView.indexPathsForSelectedRows {
            let sortedIndexPaths = DataSourceManager.shared.sortIndexPathsInDescendingOrder(indexPaths)
            for indexPath in sortedIndexPaths {
                dataSource?.recoverContact(at: indexPath)
            }
        } else {
            if (dataSource?.data.isEmpty) != nil {
                Alert.showNoContactsAlert(on: self)
            } else {
                Alert.showNoContactSelectedAlert(on: self)
            }
        }
    }
    
    @objc private func handleRefresh() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            self.dataSource?.reload()
            self.refreshControl.endRefreshing()
        }
    }
}

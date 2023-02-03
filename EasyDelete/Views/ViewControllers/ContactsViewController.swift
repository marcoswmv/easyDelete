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
    private let refreshControl: UIRefreshControl = UIRefreshControl()
    
    var dataSource: ContactsDataSource?
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDataSource()
        configureUIEssentials()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        dataSource?.reload()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        editingMode(disable: true)
    }
    
    fileprivate func configureUIEssentials() {
        configureTableView()
        configureNavigationBar()
        configureToolbar()
        configureSearchBarController()
        configureRefreshControl()
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
        
        layoutTableViewHeader(with: String(dataSource?.contactsCount() ?? 0))
    }
    
    func layoutTableViewHeader(with text: String) {
        let textLabel = UILabel(frame: CGRect(x: 0, y: 0,
                                                width: tableView.bounds.size.width,
                                                height: tableView.bounds.size.height))
        textLabel.text = "\(String(describing: text)) \(Consts.contacts)"
        textLabel.textAlignment = .center
        
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        customView.backgroundColor = .systemBackground
        customView.addSubview(textLabel)
        
        textLabel.enableAutoLayout()
        textLabel.setConstraints(to: customView)
        
        tableView.tableHeaderView = customView
    }
    
    fileprivate func configureNavigationBar() {
        navigationItem.title = Consts.ContactsList.title
        navigationController?.navigationBar.prefersLargeTitles = true
        let leftNavBarButton = UIBarButtonItem(title: Consts.ContactsList.deleted, style: .plain, target: self, action: #selector(handlePushDeleted))
        let rightNavBarButton = UIBarButtonItem(title: Consts.ListScreen.select, style: .plain, target: self, action: #selector(handleSelect))
        navigationItem.leftBarButtonItem = leftNavBarButton
        navigationItem.rightBarButtonItem = rightNavBarButton
    }
    
    fileprivate func configureToolbar() {
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let deleteButton = UIBarButtonItem(title: Consts.ContactsList.delete, style: .plain, target: self, action: #selector(handleDelete))
        deleteButton.tintColor = .red
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(handleDone))
        
        toolbarItems = [deleteButton, flexibleSpace, doneButton]
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
    
    fileprivate func editingMode(disable: Bool) {
        navigationItem.leftBarButtonItem?.isEnabled = disable
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
        } else {
            Alert.showNoContactSelectedAlert(on: UIApplication.topViewController()!)
        }
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
            self.dataSource?.reload()
            self.refreshControl.endRefreshing()
        }
    }
}

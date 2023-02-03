//
//  DeletedContactsViewControllerOld.swift
//  EasyDelete
//
//  Created by Marcos Vicente on 06.08.2021.
//

import UIKit

class DeletedContactsViewControllerOld: UIViewController {
    
//    var tableView: UITableView!
//    var searchController: UISearchController!
//    private var refreshControl: UIRefreshControl!
//    private var selectAllButton: UIBarButtonItem!
//    private var rightNavBarButton: UIBarButtonItem!
//    
//    var tableViewTapRecognizer: UITapGestureRecognizer!
//    
//    var dataSource: DeletedContactsDataSource?
//    var timer: Timer?
//    var isAllSelected: Bool = false
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        configureUIComponents()
//        setupDataSource()
//        continuouslyUpdateDeletedContactsRemainingTime()
//        
//        dataSource?.updateCountText = { [weak self] count in
//            guard let self = self else { return }
//            // swiftlint:disable:next empty_count
//            if count > 0 {
//                self.navigationItem.title = "Selected \(count) contact\(count >= 2 ? "s" : "")"
//            } else {
//                self.navigationItem.title = Consts.DeletedContactsList.title
//            }
//        }
//    }
//    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        
//        manageDeletedContacts(enable: false)
//    }
//    
//    private func configureUIComponents() {
//        configureTableView()
//        configureNavigationBar()
//        configureToolbar()
//        configureSearchBarController()
//        configureRefreshControl()
//    }
//    
//    private func setupDataSource() {
//        dataSource = DeletedContactsDataSource(tableView: tableView)
//        dataSource?.reload()
//    }
//    
//    private func configureTableView() {
//        tableView = UITableView()
//        view.addSubview(tableView)
//        
//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Consts.DeletedContactsList.cell)
//        tableView.allowsMultipleSelectionDuringEditing = true
//        tableView.enableAutoLayout()
//        tableView.setConstraints(to: view)
//        
//        tableViewTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapOnTable))
//        
////        layoutTableViewFooter(with: String(dataSource?.contactsCount() ?? 0))
//    }
//    
//    func layoutTableViewFooter(with text: String) {
//        if text == "0" {
//            tableView.tableFooterView = nil
//        } else {
//            let textLabel = UILabel(frame: CGRect(x: 0, y: 0,
//                                                  width: tableView.bounds.size.width,
//                                                  height: tableView.bounds.size.height))
//            textLabel.text = "\(String(describing: text)) \(Consts.contacts)"
//            textLabel.textAlignment = .center
//            textLabel.textColor = .gray
//            textLabel.font = UIFont.systemFont(ofSize: 15)
//            
//            let customView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40))
//            customView.backgroundColor = .systemBackground
//            customView.addSubview(textLabel)
//            
//            textLabel.enableAutoLayout()
//            textLabel.setConstraints(to: customView)
//            
//            tableView.tableFooterView = customView
//        }
//    }
//    
//    private func configureNavigationBar() {
//        navigationItem.title = Consts.DeletedContactsList.title
//        navigationController?.navigationBar.prefersLargeTitles = true
//        let buttonTitle = Consts.DeletedContactsList.manage
//        rightNavBarButton = UIBarButtonItem(title: buttonTitle, style: .plain, target: self, action: #selector(handleManage))
//        navigationItem.rightBarButtonItem = rightNavBarButton
//    }
//    
//    private func configureToolbar() {
//        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
//        let deleteButton = UIBarButtonItem(title: Consts.DeletedContactsList.delete, style: .plain, target: self, action: #selector(handleDelete))
//        deleteButton.tintColor = .red
//        let recoverButton = UIBarButtonItem(title: Consts.DeletedContactsList.recover, style: .plain, target: self, action: #selector(handleRecover))
//        selectAllButton = UIBarButtonItem(title: Consts.DeletedContactsList.selectAll, style: .plain, target: self, action: #selector(handleSelectAll))
//        
//        toolbarItems = [deleteButton, flexibleSpace, recoverButton, flexibleSpace, selectAllButton]
//    }
//    
//    private func createBarButton(with icon: String, action: Selector?) -> UIBarButtonItem {
//        let button: UIButton = UIButton(type: .system)
//        button.setImage(UIImage(systemName: icon), for: .normal)
//        if let action = action {
//            button.addTarget(self, action: action, for: .touchUpInside)
//        }
//        
//        return UIBarButtonItem(customView: button)
//    }
//    
//    private func configureSearchBarController() {
//        searchController = UISearchController(searchResultsController: nil)
//        navigationItem.searchController = searchController
//        navigationItem.hidesSearchBarWhenScrolling = false
//        self.definesPresentationContext = true
//        searchController.searchBar.delegate = self
//        searchController.obscuresBackgroundDuringPresentation = false
//    }
//    
//    private func configureRefreshControl() {
//        refreshControl = UIRefreshControl()
//        tableView.refreshControl = self.refreshControl
//        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
//    }
//    
//    private func manageDeletedContacts(enable: Bool) {
//        if enable {
//            navigationItem.title = Consts.DeletedContactsList.title
//            rightNavBarButton = UIBarButtonItem(title: Consts.ListScreen.done, style: .plain, target: self, action: #selector(handleDone))
//        } else {
//            let buttonTitle = Consts.DeletedContactsList.manage
//            rightNavBarButton = UIBarButtonItem(title: buttonTitle, style: .plain, target: self, action: #selector(handleManage))
//        }
//        navigationItem.rightBarButtonItem = rightNavBarButton
//        navigationController?.setToolbarHidden(!enable, animated: true)
//        tableView.setEditing(enable, animated: enable)
//    }
//    
//    private func continuouslyUpdateDeletedContactsRemainingTime() {
//        let dayInSecondsTimeInterval = TimeInterval(Consts.Numbers.dayInSeconds)
//        let target = dataSource ?? DeletedContactsDataSource(tableView: tableView)
//        let selector = #selector(dataSource?.updateContactsRemainingDays)
//        Timer.scheduledTimer(timeInterval: dayInSecondsTimeInterval, target: target, selector: selector, userInfo: nil, repeats: true)
//    }
//    
//    // MARK: - Handlers
//    
//    @objc private func handleManage() {
//        manageDeletedContacts(enable: true)
//    }
//    
//    @objc private func handleDelete() {
//        if let indexPaths = self.tableView.indexPathsForSelectedRows {
//            Alert.showActionSheetToAskForConfirmationToDelete(on: self, numberOfContacts: indexPaths.count) { [weak self] confirmation in
//                guard let self = self else { return }
////                if confirmation {
////                    let sortedIndexPaths = DataSourceManager.shared.sortIndexPathsInDescendingOrder(indexPaths)
////                    var indexPathsToDelete = EDTypes.IndexPaths()
////                    for indexPath in sortedIndexPaths {
////                        indexPathsToDelete.append(indexPath)
////                    }
////                    self.dataSource?.deleteContact(at: indexPathsToDelete)
////                }
//            }
//            if isAllSelected {
//                selectAllButton.title = Consts.DeletedContactsList.selectAll
//                isAllSelected = false
//            }
//            navigationItem.title = Consts.DeletedContactsList.title
//        } else {
//            if let data = dataSource?.data, data.isEmpty {
//                Alert.showNoContactsAlert(on: self)
//            } else {
//                Alert.showNoContactSelectedAlert(on: self)
//            }
//        }
//    }
//    
//    @objc private func handleDone() {
//        manageDeletedContacts(enable: false)
//    }
//    
//    @objc private func handleRecover() {
//        if let indexPaths = self.tableView.indexPathsForSelectedRows {
////            let sortedIndexPaths = DataSourceManager.shared.sortIndexPathsInDescendingOrder(indexPaths)
////            for indexPath in sortedIndexPaths {
////                dataSource?.recoverContact(at: indexPath)
////            }
//            dataSource?.needsToFetchFromContactStore = true
//            dataSource?.reload()
//            if isAllSelected {
//                selectAllButton.title = Consts.DeletedContactsList.selectAll
//                isAllSelected = false
//            }
//            navigationItem.title = Consts.DeletedContactsList.title
//        } else {
//            if let data = dataSource?.data, data.isEmpty {
//                Alert.showNoContactsAlert(on: self)
//            } else {
//                Alert.showNoContactSelectedAlert(on: self)
//            }
//        }
//    }
//    
//    @objc private func handleRefresh() {
//        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
//            self.dataSource?.reload()
//            self.refreshControl.endRefreshing()
//        }
//    }
//    
//    @objc private func handleSelectAll() {
//        if isAllSelected {
//            for section in 0..<tableView.numberOfSections {
//                for row in 0..<tableView.numberOfRows(inSection: section) {
//                    tableView.deselectRow(at: IndexPath(row: row, section: section), animated: true)
//                }
//            }
//            selectAllButton.title = Consts.DeletedContactsList.selectAll
//            isAllSelected = false
//        } else {
//            for section in 0..<tableView.numberOfSections {
//                for row in 0..<tableView.numberOfRows(inSection: section) {
//                    tableView.selectRow(at: IndexPath(row: row, section: section), animated: true, scrollPosition: .none)
//                }
//            }
//            selectAllButton.title = Consts.DeletedContactsList.unselectAll
//            isAllSelected = true
//        }
//    }
//    
//    @objc private func handleTapOnTable() {
//        print("Blocking user interaction with table view")
//    }
}

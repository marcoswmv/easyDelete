//
//  DeletedContactsListViewController.swift
//  EasyDelete
//
//  Created by Marcos Vicente on 03/02/23.
//

import UIKit
import Combine

class DeletedContactsListViewController: UITableViewController {
    
    // MARK: - Properties and Initialization
    
    private var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
    var viewModel: ContactsListViewModel
    var timer: Timer?
    var isAllSelected: Bool = false
    
    init(viewModel: ContactsListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Declaration
    
    private var selectAllButton: UIBarButtonItem!
    private var rightNavBarButton: UIBarButtonItem!
    
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        
        return searchController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        viewModel.fetchContacts()
    }
    
    private func setupUI() {
        setupNavigationBar()
        setupTableView()
        setupToolbar()
    }
    
    private func bindViewModel() {
        viewModel.$contactsViewModels.sink { [weak self] _ in
            guard let `self` = self else { return }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }.store(in: &cancellables)
        
        viewModel.$error.sink { [weak self] error in
            guard let `self` = self, let error else { return }
            DispatchQueue.main.async {
                Alert.showErrorAlert(on: self, message: error.localizedDescription)
            }
        }.store(in: &cancellables)
    }
    
    private func setupNavigationBar() {
        navigationItem.title = Consts.DeletedContactsList.title
        navigationController?.navigationBar.prefersLargeTitles = true
        
        rightNavBarButton = UIBarButtonItem(title: Consts.DeletedContactsList.manage, style: .plain, target: self, action: #selector(handleManage))
        navigationItem.rightBarButtonItem = rightNavBarButton
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleNavigationBarTap))
        navigationController?.navigationBar.addGestureRecognizer(tapGesture)
    }
    
    private func setupTableView() {
        tableView.register(DeletedContactTableViewCell.self, forCellReuseIdentifier: DeletedContactTableViewCell.identifier)
        tableView.allowsMultipleSelectionDuringEditing = true
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    private func setupToolbar() {
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let deleteButton = UIBarButtonItem(title: Consts.DeletedContactsList.delete, style: .plain, target: self, action: #selector(handleDelete))
        deleteButton.tintColor = .red
        let recoverButton = UIBarButtonItem(title: Consts.DeletedContactsList.recover, style: .plain, target: self, action: #selector(handleRecover))
        selectAllButton = UIBarButtonItem(title: Consts.DeletedContactsList.selectAll, style: .plain, target: self, action: #selector(handleSelectAll))
        
        toolbarItems = [deleteButton, flexibleSpace, recoverButton, flexibleSpace, selectAllButton]
    }
    
    private func manageDeletedContacts(enable: Bool) {
        if enable {
            navigationItem.title = Consts.DeletedContactsList.title
            rightNavBarButton = UIBarButtonItem(title: Consts.ListScreen.done, style: .plain, target: self, action: #selector(handleDone))
        } else {
            let buttonTitle = Consts.DeletedContactsList.manage
            rightNavBarButton = UIBarButtonItem(title: buttonTitle, style: .plain, target: self, action: #selector(handleManage))
        }
        navigationItem.rightBarButtonItem = rightNavBarButton
        navigationController?.setToolbarHidden(!enable, animated: true)
        tableView.setEditing(enable, animated: enable)
    }
}

// MARK: - Handlers

extension DeletedContactsListViewController {
    
    @objc private func handleNavigationBarTap() {
        view.endEditing(true)
        navigationController?.navigationBar.endEditing(true)
        tableView.scrollToRow(at: .init(row: 0, section: 0), at: .top, animated: true)
    }
    
    @objc private func handleManage() {
        manageDeletedContacts(enable: true)
    }
    
    @objc private func handleDone() {
        manageDeletedContacts(enable: false)
    }
    
    @objc private func handleRefresh() {
        viewModel.fetchContacts { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.refreshControl?.endRefreshing()
            }
        }
    }
    
    @objc private func handleDelete() {
        if let indexPaths = tableView.indexPathsForSelectedRows {
            Alert.showActionSheetToAskForConfirmationToDelete(on: self, numberOfContacts: indexPaths.count) { [weak self] confirmation in
                guard let `self` = self else { return }
                if confirmation {
                    indexPaths.sorted(by: { $0 > $1 }).forEach { indexPath in
                        if self.viewModel.contactsViewModels.indices.contains(indexPath.section),
                           self.viewModel.contactsViewModels[indexPath.section].names.indices.contains(indexPath.row) {
                            let contactToDeleteID = self.viewModel.contactsViewModels[indexPath.section].names
                                .filter { $0.isDeleted }[indexPath.row].identifier
                            self.viewModel.deleteContact(with: contactToDeleteID, permanently: true)
                        }
                    }
                }
            }
            if isAllSelected {
                selectAllButton.title = Consts.DeletedContactsList.selectAll
                isAllSelected = false
            }
            navigationItem.title = Consts.DeletedContactsList.title
            
        } else {
            if viewModel.contactsViewModels.isEmpty {
                Alert.showNoContactsAlert(on: self)
            } else {
                Alert.showNoContactSelectedAlert(on: self)
            }
        }
    }
    
    @objc private func handleRecover() {
//        if let indexPaths = self.tableView.indexPathsForSelectedRows {
//            let sortedIndexPaths = DataSourceManager.shared.sortIndexPathsInDescendingOrder(indexPaths)
//            for indexPath in sortedIndexPaths {
//                dataSource?.recoverContact(at: indexPath)
//            }
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
    }
    
    @objc private func handleSelectAll() {
        if isAllSelected {
            for section in 0..<tableView.numberOfSections {
                for row in 0..<tableView.numberOfRows(inSection: section) {
                    tableView.deselectRow(at: IndexPath(row: row, section: section), animated: true)
                }
            }
            selectAllButton.title = Consts.DeletedContactsList.selectAll
            isAllSelected = false
        } else {
            for section in 0..<tableView.numberOfSections {
                for row in 0..<tableView.numberOfRows(inSection: section) {
                    tableView.selectRow(at: IndexPath(row: row, section: section), animated: true, scrollPosition: .none)
                }
            }
            selectAllButton.title = Consts.DeletedContactsList.unselectAll
            isAllSelected = true
        }
    }
}

    // MARK: - Table view data source

extension DeletedContactsListViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.contactsViewModels.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if viewModel.contactsViewModels[section].names.allSatisfy({ $0.isDeleted == false }) {
            return nil
        }
        return viewModel.contactsViewModels[section].letter
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.contactsViewModels[section].names.filter { $0.isDeleted }.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DeletedContactTableViewCell.identifier, 
                                                       for: indexPath) as? DeletedContactTableViewCell else { return DeletedContactTableViewCell() }
        
        let contactViewModel = viewModel.contactsViewModels[indexPath.section].names.filter { $0.isDeleted }[indexPath.row]
        
        let name = contactViewModel.name
        let phoneNumbers = contactViewModel.phoneNumbers
        
        cell.textLabel?.lineBreakMode = .byWordWrapping
        cell.textLabel?.font = .boldSystemFont(ofSize: 15)
        cell.textLabel?.text = name
        
        cell.detailTextLabel?.lineBreakMode = .byWordWrapping
        cell.detailTextLabel?.text = phoneNumbers.joined(separator: ", ")
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchController.searchBar.endEditing(true)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            Alert.showActionSheetToAskForConfirmationToDelete(on: self) { [weak self] confirmation in
                guard let `self` = self else { return }
                if confirmation {
                    let contactToDeleteID = self.viewModel.contactsViewModels[indexPath.section].names
                        .filter { $0.isDeleted }[indexPath.row].identifier
                    self.viewModel.deleteContact(with: contactToDeleteID, permanently: true)
                }
            }
        }  
    }
//    
//    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        let recoverAction = UIContextualAction(style: .normal, title: Consts.DeletedContactsList.recover) { [weak self] (_, _, completionHandler) in
//            guard let self = self else { return }
////            self.recoverContact(at: indexPath)
////            self.reload()
//            completionHandler(true)
//        }
//        recoverAction.backgroundColor = .link
//        return UISwipeActionsConfiguration(actions: [recoverAction])
//    }
}

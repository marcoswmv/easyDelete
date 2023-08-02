//
//  DeletedContactsListViewController.swift
//  EasyDelete
//
//  Created by Marcos Vicente on 03/02/23.
//

import UIKit
import Combine

final class DeletedContactsListViewController: UITableViewController {
    
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
    
    private lazy var countLabel: UILabel = {
        let countLabel = UILabel(frame: CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: 80.0)))
        countLabel.textColor = .gray
        countLabel.textAlignment = .center
        return countLabel
    }()
    
    private lazy var noContactsLabel: UILabel = {
        let countLabel = UILabel(frame: CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: 80.0)))
        countLabel.textColor = .gray
        countLabel.textAlignment = .center
        return countLabel
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        viewModel.fetchContacts()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setToolbarHidden(true, animated: true)
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
                let contactsCount = self.viewModel.contactsViewModels.reduce(0) { $0 + $1.names.filter { $0.isDeleted }.count }
                let hasContacts = contactsCount > 0
                
                self.countLabel.isHidden = !hasContacts
                self.noContactsLabel.isHidden = hasContacts
                self.enableRightNavigationBarButton(hasContacts)
                
                if hasContacts {
                    self.countLabel.text = "\(contactsCount) \(Consts.contacts)"
                } else {
                    self.noContactsLabel.text = Consts.ListScreen.emptyList
                }
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
        
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        
        rightNavBarButton = UIBarButtonItem(title: Consts.DeletedContactsList.manage, 
                                            style: .plain, 
                                            target: self, 
                                            action: #selector(handleManage))
        navigationItem.rightBarButtonItem = rightNavBarButton
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleNavigationBarTap))
        navigationController?.navigationBar.addGestureRecognizer(tapGesture)
    }
    
    private func enableRightNavigationBarButton(_ enable: Bool) {
        rightNavBarButton.isEnabled = enable
        rightNavBarButton.tintColor = enable ? .link : .gray
    }
    
    private func setupTableView() {
        tableView.register(DeletedContactTableViewCell.self, forCellReuseIdentifier: DeletedContactTableViewCell.identifier)
        tableView.allowsMultipleSelectionDuringEditing = true
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        tableView.tableFooterView = countLabel
        tableView.backgroundView = noContactsLabel
    }
    
    private func setupToolbar() {
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let deleteButton = UIBarButtonItem(title: Consts.DeletedContactsList.delete, 
                                           style: .plain, 
                                           target: self, 
                                           action: #selector(handleDelete))
        deleteButton.tintColor = .red
        let recoverButton = UIBarButtonItem(title: Consts.DeletedContactsList.recover, 
                                            style: .plain, 
                                            target: self, 
                                            action: #selector(handleRecover))
        selectAllButton = UIBarButtonItem(title: Consts.DeletedContactsList.selectAll, 
                                          style: .plain, 
                                          target: self, 
                                          action: #selector(handleSelectAll))
        
        toolbarItems = [deleteButton, flexibleSpace, recoverButton, flexibleSpace, selectAllButton]
    }
    
    private func manageDeletedContacts(enable: Bool) {
        if enable {
            navigationItem.title = Consts.DeletedContactsList.title
            rightNavBarButton = UIBarButtonItem(title: Consts.ListScreen.done, 
                                                style: .plain, 
                                                target: self, 
                                                action: #selector(handleDone))
        } else {
            let buttonTitle = Consts.DeletedContactsList.manage
            rightNavBarButton = UIBarButtonItem(title: buttonTitle, 
                                                style: .plain, 
                                                target: self, 
                                                action: #selector(handleManage))
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
        if viewModel.contactsViewModels.filter({ $0.names.allSatisfy({ $0.isDeleted }) }).isEmpty == false {
            tableView.scrollToRow(at: .init(row: 0, section: 0), at: .top, animated: true)
        }
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
        if let indexPaths = self.tableView.indexPathsForSelectedRows {
            indexPaths.sorted(by: { $0 > $1 }).forEach { indexPath in
                if self.viewModel.contactsViewModels.indices.contains(indexPath.section),
                   self.viewModel.contactsViewModels[indexPath.section].names.indices.contains(indexPath.row) {
                    let contactToDeleteID = self.viewModel.contactsViewModels[indexPath.section].names
                        .filter { $0.isDeleted }[indexPath.row].identifier
                    self.viewModel.recoverContact(with: contactToDeleteID)
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
        guard let section = viewModel.contactsViewModels[safe: section],
              section.names.allSatisfy({ $0.isDeleted == false }) == false else { return nil }
        return section.letter
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.contactsViewModels[section].names.filter { $0.isDeleted }.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: DeletedContactTableViewCell.identifier, 
            for: indexPath) as? DeletedContactTableViewCell,
              let section = viewModel.contactsViewModels[safe: indexPath.section],
              let contactViewModel = section.names.filter({ $0.isDeleted })[safe: indexPath.row] else { 
            print("Something went wrong!")
            return DeletedContactTableViewCell()
        }
        
        cell.fill(with: contactViewModel)
        
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
                
                if confirmation,
                   self.viewModel.contactsViewModels.indices.contains(indexPath.section),
                   self.viewModel.contactsViewModels[indexPath.section].names.indices.contains(indexPath.row) {
                    
                    let contactToDeleteID = self.viewModel.contactsViewModels[indexPath.section].names
                        .filter { $0.isDeleted }[indexPath.row].identifier
                    self.viewModel.deleteContact(with: contactToDeleteID, permanently: true)
                }
            }
        }  
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let recoverAction = UIContextualAction(style: .normal, title: Consts.DeletedContactsList.recover) { [weak self] (_, _, completionHandler) in
            guard let `self` = self else { return }
            
            if self.viewModel.contactsViewModels.indices.contains(indexPath.section),
               self.viewModel.contactsViewModels[indexPath.section].names.indices.contains(indexPath.row) {
                
                let contactToRecoverID = self.viewModel.contactsViewModels[indexPath.section].names
                    .filter { $0.isDeleted }[indexPath.row].identifier
                self.viewModel.recoverContact(with: contactToRecoverID)
                completionHandler(true)
            }
        }
        recoverAction.backgroundColor = .link
        return UISwipeActionsConfiguration(actions: [recoverAction])
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}

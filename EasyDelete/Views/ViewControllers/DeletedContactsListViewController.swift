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
    
    private var selectAllButton: UIBarButtonItem?
    private var rightNavBarButton: UIBarButtonItem?
    private var deleteButton: UIBarButtonItem?
    private var recoverButton: UIBarButtonItem?
    
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
    
    private lazy var scrollToBottomButton: UIButton = {
        let button = UIButton()
        button.imageView?.contentMode = .scaleAspectFit
        button.setImage(UIImage(systemName: "arrow.down.circle", 
                                withConfiguration: UIImage.SymbolConfiguration(weight: .light)), 
                        for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        viewModel.fetchContacts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        layoutJumpToBottomButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setToolbarHidden(true, animated: true)
        layoutJumpToBottomButton(shouldAdd: false)
    }
    
    private func setupUI() {
        setupNavigationBar()
        setupTableView()
        setupToolbar()
        
        scrollToBottomButton.addTarget(self, action: #selector(didTapScrollToBottom), for: .touchUpInside)
    }
    
    private func bindViewModel() {
        viewModel.$deletedContactsViewModels.sink { [weak self] values in
            guard let `self` = self else { return }
            DispatchQueue.main.async {
                self.scrollToBottomButton.isHidden = values.isEmpty
                let contactsCount = values.flatMap({ $0.names }).count
                let hasContacts = contactsCount > 0
                
                self.countLabel.isHidden = !hasContacts
                self.noContactsLabel.isHidden = hasContacts
                
                if hasContacts {
                    self.countLabel.text = "\(contactsCount) \(Strings.Text.contactsCountText)"
                } else {
                    self.noContactsLabel.text = Strings.Text.noContactsText
                }
                self.tableView.reloadData()
                self.updateSelectionCount()
            }
        }.store(in: &cancellables)
        
        viewModel.$successMessage.sink { [weak self] result in
            guard let `self` = self, let result else { return }
            DispatchQueue.main.async {
                self.showToast(message: result.1, action: result.0)
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
        navigationItem.title = Strings.Title.deletedContactsListTitle
        navigationController?.navigationBar.prefersLargeTitles = true
        
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        
        rightNavBarButton = UIBarButtonItem(title: Strings.Title.manageButtonTitle, 
                                            style: .plain, 
                                            target: self, 
                                            action: #selector(handleManage))
        navigationItem.rightBarButtonItem = rightNavBarButton
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleNavigationBarTap))
        navigationController?.navigationBar.addGestureRecognizer(tapGesture)
    }
    
    private func enableRightNavigationBarButton(_ enable: Bool) {
        rightNavBarButton?.isEnabled = enable
        rightNavBarButton?.tintColor = enable ? .link : .gray
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
        deleteButton = UIBarButtonItem(title: Strings.Title.deleteButtonTitle,
                                       style: .plain, 
                                       target: self, 
                                       action: #selector(handleDelete))
        deleteButton?.tintColor = .red
        recoverButton = UIBarButtonItem(title: Strings.Title.recoverButtonTitle,
                                        style: .plain, 
                                        target: self, 
                                        action: #selector(handleRecover))
        selectAllButton = UIBarButtonItem(title: Strings.Title.selectAllButtonTitle,
                                          style: .plain, 
                                          target: self, 
                                          action: #selector(handleSelectAll))
        
        if let deleteButton, let recoverButton, let selectAllButton {
            toolbarItems = [deleteButton, flexibleSpace, recoverButton, flexibleSpace, selectAllButton]
        }
    }
    
    private func layoutJumpToBottomButton(shouldAdd: Bool = true) {
        if shouldAdd {
            view.addSubview(scrollToBottomButton, aboveAll: true)
            
            scrollToBottomButton.snp.makeConstraints { make in
                make.trailing.equalToSuperview().offset(-25.0)
                make.bottom.equalToSuperview().offset(-60.0)
            }
            
            scrollToBottomButton.imageView?.snp.makeConstraints { make in
                make.size.equalTo(40.0)
            }
        } else {
            scrollToBottomButton.removeFromSuperview()
        }
    }
    
    private func manageDeletedContacts(enable: Bool) {
        if enable {
            navigationItem.title = Strings.Title.deletedContactsListTitle
            rightNavBarButton = UIBarButtonItem(title: Strings.Title.doneButtonTitle, 
                                                style: .plain, 
                                                target: self, 
                                                action: #selector(handleDone))
        } else {
            let buttonTitle = Strings.Title.manageButtonTitle
            rightNavBarButton = UIBarButtonItem(title: buttonTitle, 
                                                style: .plain, 
                                                target: self, 
                                                action: #selector(handleManage))
        }
        navigationItem.rightBarButtonItem = rightNavBarButton
        navigationController?.setToolbarHidden(!enable, animated: true)
        tableView.setEditing(enable, animated: enable)
        updateSelectionCount()
        
        scrollToBottomButton.snp.remakeConstraints { make in
            make.trailing.equalToSuperview().offset(-25.0)
            make.bottom.equalToSuperview().offset(enable ? -100.0 : -60.0)
            make.size.equalTo(40.0)
        }
    }
}

// MARK: - Handlers

extension DeletedContactsListViewController {
    
    @objc private func handleNavigationBarTap() {
        view.endEditing(true)
        navigationController?.navigationBar.endEditing(true)
        if viewModel.deletedContactsViewModels.isEmpty == false {
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
                    let contactsToDelete = indexPaths.sorted(by: { $0 > $1 })
                        .compactMap { indexPath in
                            if self.viewModel.deletedContactsViewModels.indices.contains(indexPath.section),
                               self.viewModel.deletedContactsViewModels[indexPath.section].names.indices.contains(indexPath.row) {
                                return self.viewModel.deletedContactsViewModels[indexPath.section].names[indexPath.row].identifier
                            }
                            return nil
                        }
                    
                    self.viewModel.deleteContacts(with: contactsToDelete, permanently: true)
                }
            }
            if isAllSelected {
                selectAllButton?.title = Strings.Title.selectAllButtonTitle
                isAllSelected = false
            }
            navigationItem.title = Strings.Title.deletedContactsListTitle
            
        } else {
            if viewModel.deletedContactsViewModels.isEmpty {
                Alert.showNoContactsAlert(on: self)
            } else {
                Alert.showNoContactSelectedAlert(on: self)
            }
        }
    }
    
    @objc private func handleRecover() {
        if let indexPaths = self.tableView.indexPathsForSelectedRows {
            let contactIDsToRecover = indexPaths.sorted(by: { $0 > $1 })
                .compactMap { indexPath in
                    if self.viewModel.deletedContactsViewModels.indices.contains(indexPath.section),
                       self.viewModel.deletedContactsViewModels[indexPath.section].names.indices.contains(indexPath.row) {
                        return self.viewModel.deletedContactsViewModels[indexPath.section].names[indexPath.row].identifier
                    }
                    return nil
                }
            viewModel.recoverContact(with: contactIDsToRecover)
            
            if isAllSelected {
                selectAllButton?.title = Strings.Title.selectAllButtonTitle
                isAllSelected = false
            }
            navigationItem.title = Strings.Title.deletedContactsListTitle
        } else {
            if viewModel.deletedContactsViewModels.isEmpty {
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
            selectAllButton?.title = Strings.Title.selectAllButtonTitle
            isAllSelected = false
        } else {
            for section in 0..<tableView.numberOfSections {
                for row in 0..<tableView.numberOfRows(inSection: section) {
                    tableView.selectRow(at: IndexPath(row: row, section: section), animated: true, scrollPosition: .none)
                }
            }
            selectAllButton?.title = Strings.Title.unselectAllButtonTitle
            isAllSelected = true
        }
        updateSelectionCount()
    }
    
    @objc private func didTapScrollToBottom() {
        if !viewModel.deletedContactsViewModels.isEmpty {
            let lastSection = viewModel.deletedContactsViewModels.count - 1
            let lastRow = viewModel.deletedContactsViewModels[lastSection].names.count - 1
            let lastIndexPath = IndexPath(row: lastRow, 
                                          section: lastSection)
            tableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: true)
        }
    }
    
    private func updateSelectionCount() {  
        deleteButton?.title = generateButtonTitle(with: tableView.indexPathsForSelectedRows?.count)
        recoverButton?.title = generateButtonTitle(with: tableView.indexPathsForSelectedRows?.count, isRecover: true)
    }
    
    private func generateButtonTitle(with count: Int? = nil, isRecover: Bool = false) -> String {
        let text = isRecover ? Strings.Title.recoverButtonTitle : Strings.Title.deleteButtonTitle
        if let count {
            return "\(text) (\(count))"
        } else {
            return "\(text)"
        }
    }
    
    private func deleteContact(at indexPath: IndexPath) {
        let contactToDeleteID = self.viewModel.deletedContactsViewModels[indexPath.section].names[indexPath.row].identifier
        viewModel.deleteContacts(with: [contactToDeleteID], permanently: true)
    }
    
    private func recoverContact(at indexPath: IndexPath, _ completionHandler: (Bool) -> Void) {
        let contactToRecoverID = self.viewModel.deletedContactsViewModels[indexPath.section].names[indexPath.row].identifier
        self.viewModel.recoverContact(with: [contactToRecoverID])
        completionHandler(true)
    }
}

// MARK: - Table view data source

extension DeletedContactsListViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.deletedContactsViewModels.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.deletedContactsViewModels[section].letter
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.deletedContactsViewModels[section].names.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DeletedContactTableViewCell.identifier, 
                                                       for: indexPath) as? DeletedContactTableViewCell,
              viewModel.deletedContactsViewModels.indices.contains(indexPath.section),
              viewModel.deletedContactsViewModels[indexPath.section].names.indices.contains(indexPath.row)
        else { 
            print("Something went wrong!")
            return DeletedContactTableViewCell()
        }
        cell.fill(with: viewModel.deletedContactsViewModels[indexPath.section].names[indexPath.row])
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !tableView.isEditing {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        updateSelectionCount()
        searchController.searchBar.endEditing(true)
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        updateSelectionCount()
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            Alert.showActionSheetToAskForConfirmationToDelete(on: self) { [weak self] confirmation in
                guard let `self` = self else { return }
                
                if confirmation,
                   self.viewModel.deletedContactsViewModels.indices.contains(indexPath.section),
                   self.viewModel.deletedContactsViewModels[indexPath.section].names.indices.contains(indexPath.row) {
                    self.deleteContact(at: indexPath)
                }
            }
        }  
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let recoverAction = UIContextualAction(style: .normal, title: Strings.Title.recoverButtonTitle) { [weak self] (_, _, completionHandler) in
            guard let `self` = self else { return }
            
            if self.viewModel.deletedContactsViewModels.indices.contains(indexPath.section),
               self.viewModel.deletedContactsViewModels[indexPath.section].names.indices.contains(indexPath.row) {
                self.recoverContact(at: indexPath, completionHandler)
            }
        }
        recoverAction.backgroundColor = .link
        return UISwipeActionsConfiguration(actions: [recoverAction])
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let deleteAction = UIAction(title: Strings.Title.deleteButtonTitle) { [weak self] _ in
                guard let `self` = self else { return }
                self.deleteContact(at: indexPath)
            }
            
            let recoverAction = UIAction(title: Strings.Title.recoverButtonTitle) { _ in
                self.recoverContact(at: indexPath) { _ in }
            }
            
            return UIMenu(title: "", children: [recoverAction, deleteAction])
        }
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return viewModel.deletedContactsViewModels.compactMap { $0.letter }
    }
}

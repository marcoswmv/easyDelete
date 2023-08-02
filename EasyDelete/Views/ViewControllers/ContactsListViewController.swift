//
//  ContactsListViewController.swift
//  EasyDelete
//
//  Created by Marcos Vicente on 31/01/23.
//

import UIKit
import SwiftUI
import Combine

final class ContactsListViewController: UITableViewController, UISearchControllerDelegate {
    
    // MARK: - Properties and Initialization
    
    private var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
    var viewModel: ContactsListViewModel
    var timer: Timer?
    
    init(viewModel: ContactsListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .CNContactStoreDidChange, object: nil)
        print("Deinit \(self)")
    }
    // MARK: - UI Declaration
    
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
        let label = UILabel(frame: CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: 80.0)))
        label.textColor = .gray
        label.textAlignment = .center
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        viewModel.fetchContacts()
        
//        NotificationCenter.default.addObserver(self, selector: #selector(didContactsStoreChange), name: .CNContactStoreDidChange, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
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
                let contactsCount = self.viewModel.contactsViewModels.reduce(0) { $0 + $1.names.count }
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
        navigationItem.title = Consts.ContactsList.title
        navigationController?.navigationBar.prefersLargeTitles = true

        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true

        let leftNavBarButton = UIBarButtonItem(title: Consts.ContactsList.deleted, style: .plain, target: self, action: #selector(handlePushDeleted))
        rightNavBarButton = UIBarButtonItem(title: Consts.ListScreen.select, style: .plain, target: self, action: #selector(handleSelect))
        navigationItem.leftBarButtonItem = leftNavBarButton
        navigationItem.rightBarButtonItem = rightNavBarButton
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleNavigationBarTap))
        navigationController?.navigationBar.addGestureRecognizer(tapGesture)
    }
    
    private func enableRightNavigationBarButton(_ enable: Bool) {
        rightNavBarButton.isEnabled = enable
        rightNavBarButton.tintColor = enable ? .link : .gray
    }
    
    private func setupTableView() {
        tableView.register(ContactTableViewCell.self, forCellReuseIdentifier: ContactTableViewCell.identifier)
        tableView.allowsMultipleSelectionDuringEditing = true
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        tableView.tableFooterView = countLabel
        tableView.backgroundView = noContactsLabel
    }
    
    private func setupToolbar() {
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let deleteButton = UIBarButtonItem(title: Consts.ContactsList.delete, style: .plain, target: self, action: #selector(handleDelete))
        deleteButton.tintColor = .red
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(handleDone))
        
        toolbarItems = [deleteButton, flexibleSpace, doneButton]
    }
    
    func enableEditingMode(_ enable: Bool) {
        if !enable {
            self.navigationItem.title = Consts.ContactsList.title
        }
        navigationItem.leftBarButtonItem?.isEnabled = !enable
        navigationItem.rightBarButtonItem?.isEnabled = !enable
        navigationController?.setToolbarHidden(!enable, animated: true)
        searchController.searchBar.endEditing(true)
        tableView.setEditing(enable, animated: true)
        tableView.gestureRecognizers?.removeAll(where: { $0 is UITapGestureRecognizer })
    }
    
    // MARK: - Handlers
    
    @objc private func handleNavigationBarTap() {
        view.endEditing(true)
        navigationController?.navigationBar.endEditing(true)
        tableView.scrollToRow(at: .init(row: 0, section: 0), at: .top, animated: true)
    }
    
    @objc private func handleSelect() {
        enableEditingMode(true)
    }
    
    @objc private func handleDone() {
        enableEditingMode(false)
    }
    
    @objc private func handleDelete() {
        if let indexPaths = tableView.indexPathsForSelectedRows {
            indexPaths.sorted(by: { $0 > $1 }).forEach { indexPath in
                if self.viewModel.contactsViewModels.indices.contains(indexPath.section),
                   self.viewModel.contactsViewModels[indexPath.section].names.indices.contains(indexPath.row) {
                    let contactToDeleteID = viewModel.contactsViewModels[indexPath.section].names
                        .filter { $0.isDeleted == false }[indexPath.row].identifier
                    viewModel.deleteContact(with: contactToDeleteID)
                }
            }
        } else {
            Alert.showNoContactSelectedAlert(on: self)
        }
    }
    
    @objc private func handlePushDeleted() {
        let deletedContactsVC = DeletedContactsListViewController(viewModel: viewModel)
        navigationController?.pushViewController(deletedContactsVC, animated: true)
    }
    
    @objc private func handleRefresh() {
        viewModel.fetchContacts { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.refreshControl?.endRefreshing()
            }
        }
    }
    
    @objc func didContactsStoreChange(notification: Notification) {
        viewModel.fetchContacts()
    }
}

// MARK: - Table view data source

extension ContactsListViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.contactsViewModels.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if viewModel.contactsViewModels[section].names.allSatisfy({ $0.isDeleted }) {
            return nil
        }
        return viewModel.contactsViewModels[section].letter
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.contactsViewModels[section].names.filter { $0.isDeleted == false }.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ContactTableViewCell.identifier, 
                                                       for: indexPath) as? ContactTableViewCell,
              viewModel.contactsViewModels.indices.contains(indexPath.section),
              viewModel.contactsViewModels[indexPath.section].names
            .filter({ $0.isDeleted == false }).indices.contains(indexPath.row) else { return ContactTableViewCell() }
        
        let contactViewModel = viewModel.contactsViewModels[indexPath.section].names.filter { $0.isDeleted == false }[indexPath.row]
        
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
        if !tableView.isEditing {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        searchController.searchBar.endEditing(true)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let contactToDeleteID = viewModel.contactsViewModels[indexPath.section].names
                .filter { $0.isDeleted == false }[indexPath.row].identifier
            viewModel.deleteContact(with: contactToDeleteID)
        }  
    }
}

#if DEBUG
private struct ViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> some UIViewController {
        return ContactsListViewController(viewModel: ContactsListViewModel())
    }    
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    }
}

struct DynamicFontTableViewControllerPreview: PreviewProvider {
    static var previews: some View {
        ViewControllerRepresentable()
    }
}
#endif

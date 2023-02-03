//
//  ContactDetailViewController.swift
//  EasyDelete
//
//  Created by Marcos Vicente on 16.08.2021.
//

import UIKit

class ContactDetailViewController: UIViewController {
    
//    private var photoImageView: UIImageView = UIImageView()
//    private let nameLabel: UILabel = UILabel()
//    private let jobTitleLabel: UILabel = UILabel()
//    private let labelsStackView: UIStackView = UIStackView()
//    private var itemsTableView: UITableView = UITableView(frame: .zero, style: .insetGrouped)
//    
//    var contact: Contact = Contact()
//    var dataSource: ContactDetailsDataSource?
//    
//    convenience init(contact: Contact) {
//        self.init()
//        self.contact = contact
//    }
//    
//    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
//        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        view.backgroundColor = .systemBackground
//        
//        configureNavigationBar()
//        setupDataSource()
//        contentLayout()
//    }
//    
//    private func setupDataSource() {
//        dataSource = ContactDetailsDataSource(tableView: itemsTableView, contact: self.contact)
//        dataSource?.reload()
//    }
//    
//    private func configureNavigationBar() {
//        navigationItem.title = Consts.ContactDetailView.title
//        navigationController?.navigationBar.prefersLargeTitles = false
//        let rightNavBarButton = UIBarButtonItem(title: Consts.ListScreen.done, style: .plain, target: self, action: #selector(handleDismiss))
//        navigationItem.rightBarButtonItem = rightNavBarButton
//    }
//    
//    private func contentLayout() {
//        layoutImageView()
//        layoutNameLabel()
//        layoutJobTitleLabel()
//        addLabelsToStackView()
//        layoutItemsTableView()
//    }
//    
//    private func layoutImageView() {
//        let photoPlaceholder = UIImage(named: Consts.contactPhotoPlaceholder)
//        
//        let contactPhoto = UIImage(data: contact.thumbnailPhoto)
//        photoImageView = UIImageView(image: contactPhoto ?? photoPlaceholder)
//        photoImageView.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
//        photoImageView.backgroundColor = .secondarySystemBackground
//        photoImageView.contentMode = contactPhoto == nil ? .center : .scaleAspectFit
//        photoImageView.layer.cornerRadius = photoImageView.frame.width / 2
//        photoImageView.layer.masksToBounds = true
//        photoImageView.layer.borderWidth = 1.0
//        photoImageView.layer.borderColor = UIColor.lightGray.cgColor
//        
//        view.addSubview(photoImageView)
//        
//        photoImageView.enableAutoLayout()
//        photoImageView.setTopConstraint(to: view, top: 90)
//        photoImageView.setHorizontalCenterConstraint(to: view)
//        photoImageView.setSizeConstraint(width: 200, height: 200)
//    }
//    
//    private func layoutNameLabel() {
//        
//        if let givenName = contact.givenName, let familyName = contact.familyName {
//            let contactName = "\(givenName) \(familyName)"
//            
//            nameLabel.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width / 4, height: UIScreen.main.bounds.height)
//            nameLabel.numberOfLines = 0
//            nameLabel.textAlignment = .center
//            nameLabel.font = UIFont.boldSystemFont(ofSize: 25)
//            nameLabel.text = contactName
//            
//            view.addSubview(nameLabel)
//        }
//    }
//    
//    private func layoutJobTitleLabel() {
//        let jobTitle = "\(contact.jobTitle)"
//        
//        jobTitleLabel.font = UIFont.systemFont(ofSize: 17)
//        jobTitleLabel.numberOfLines = 0
//        jobTitleLabel.textAlignment = .center
//        jobTitleLabel.text = jobTitle
//        
//        view.addSubview(jobTitleLabel)
//    }
//    
//    private func addLabelsToStackView() {
//        
//        labelsStackView.axis = .vertical
//        labelsStackView.distribution = .fillEqually
//        labelsStackView.alignment = .center
//        labelsStackView.spacing = 20
//        
//        labelsStackView.addArrangedSubview(nameLabel)
//        
//        if !contact.jobTitle.isEmpty {
//            labelsStackView.addArrangedSubview(jobTitleLabel)
//        }
//        
//        view.addSubview(labelsStackView)
//        
//        labelsStackView.enableAutoLayout()
//        labelsStackView.setTopConstraint(to: photoImageView, bottom: 30)
//        labelsStackView.setHorizontalCenterConstraint(to: view)
//        labelsStackView.setWidthConstraint(width: UIScreen.main.bounds.width - 40)
//    }
//    
//    private func layoutItemsTableView() {
//        itemsTableView.register(UITableViewCell.self, forCellReuseIdentifier: Consts.ContactDetailView.contactDetailsCell)
//        
//        view.addSubview(itemsTableView)
//        
//        itemsTableView.enableAutoLayout()
//        itemsTableView.setTopConstraint(to: labelsStackView, bottom: 10)
//        itemsTableView.setHorizontalCenterConstraint(to: view)
//        itemsTableView.setSizeConstraint(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
//    }
//    
//    // MARK: - Handlers
//    
//    @objc private func handleDismiss() {
//        self.navigationController?.dismiss(animated: true, completion: nil)
//    }
}

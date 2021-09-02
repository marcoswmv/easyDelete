//
//  BaseDataSource.swift
//  myContacts
//
//  Created by Marcos Vicente on 30.07.2020.
//  Copyright © 2020 Antares Software Group. All rights reserved.
//

import UIKit

protocol BaseDataSourceDelegate: BaseDataSource {
    func startQuery(with text: String)
    func deleteContact(at indexPaths: EDTypes.IndexPaths)
    func recoverContact(at indexPath: IndexPath)
}

class BaseDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    private(set) var tableView: UITableView
    var onError: ((_ error: Error) -> Void)?
    
    init(tableView: UITableView) {
        self.tableView = tableView
        
        super.init()
        setup()
    }
    
    func setup() {
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    func reload() {
        fatalError("Not implemented")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fatalError("Not implemented")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        fatalError("Not implemented")
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    func addTableViewBackgroundView(with text: String) {
        let noResultsLabel = UILabel(frame: CGRect(x: 0, y: 0,
                                                width: tableView.bounds.size.width,
                                                height: tableView.bounds.size.height))
        noResultsLabel.text = text
        noResultsLabel.textAlignment = .center
        tableView.backgroundView = noResultsLabel
        tableView.separatorStyle = .none
    }
    
    func setTableViewDefaultStyle() {
        tableView.backgroundView = UIView()
        tableView.separatorStyle = .singleLine
    }
    
    func layoutTableViewFooter(with text: String) {
        if text == "0" {
            tableView.tableFooterView = nil
        } else {
            let textLabel = UILabel(frame: CGRect(x: 0, y: 0,
                                                  width: tableView.bounds.size.width,
                                                  height: tableView.bounds.size.height))
            textLabel.text = "\(String(describing: text)) \(Consts.contacts)"
            textLabel.textAlignment = .center
            textLabel.textColor = .gray
            textLabel.font = UIFont.systemFont(ofSize: 15)
            
            let customView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40))
            customView.backgroundColor = .systemBackground
            customView.addSubview(textLabel)
            
            textLabel.enableAutoLayout()
            textLabel.setConstraints(to: customView)
            
            tableView.tableFooterView = customView
        }
    }
}

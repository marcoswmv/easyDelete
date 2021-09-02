//
//  ContactsVC+SearchBarDelegate.swift
//  EasyDelete
//
//  Created by Marcos Vicente on 04.08.2021.
//

import UIKit

extension ContactsViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        cancelSearchTimer()
        search(query: searchBar.text)
        if tableView.isEditing {
            tableView.removeGestureRecognizer(tableViewTapRecognizer)
        }
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if !tableView.isEditing {
            tableView.addGestureRecognizer(tableViewTapRecognizer)
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        cancelSearchTimer()
        search(query: searchBar.text)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        cancelSearchTimer()
        search(query: nil)
        searchBar.text = ""
        dataSource?.reload()
        tableView.removeGestureRecognizer(tableViewTapRecognizer)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchIfNeeded(query: searchText)
    }
    
    private func cancelSearchTimer() {
        if timer != nil, timer!.isValid {
            timer?.invalidate()
            timer = nil
        }
    }
    
    private func searchIfNeeded(query: String?) {
        cancelSearchTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: false, block: { [weak self] (_) in
            guard let self = self else { return }
            self.search(query: query)
        })
    }
    
    private func search(query: String?) {
        if let searchText = query {
            dataSource?.startQuery(with: searchText)
        } else {
            dataSource?.startQuery(with: "")
        }
    }
}

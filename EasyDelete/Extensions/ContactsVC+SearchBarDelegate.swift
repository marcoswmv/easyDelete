//
//  ContactsVC+SearchBarDelegate.swift
//  EasyDelete
//
//  Created by Marcos Vicente on 04.08.2021.
//

import UIKit

extension ContactsListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        cancelSearchTimer()
        search(query: searchBar.text)
        if tableView.isEditing {
            tableView.gestureRecognizers?.removeAll(where: { $0 is UITapGestureRecognizer })
        }
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if !tableView.isEditing {
            tableView.gestureRecognizers?.removeAll(where: { $0 is UITapGestureRecognizer })
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
        tableView.reloadData()
        tableView.gestureRecognizers?.removeAll(where: { $0 is UITapGestureRecognizer })
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchIfNeeded(query: searchText)
    }
    
    private func cancelSearchTimer() {
        if let timer, timer.isValid {
            timer.invalidate()
            self.timer = nil
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
        viewModel.startQuery(with: query)
    }
}

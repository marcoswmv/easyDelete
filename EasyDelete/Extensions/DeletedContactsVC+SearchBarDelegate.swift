//
//  DeletedContactsVC+SearchBarDelegate.swift
//  EasyDelete
//
//  Created by Marcos Vicente on 06.08.2021.
//

import UIKit

extension DeletedContactsViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        cancelSearchTimer()
        search(query: searchBar.text)
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
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchIfNeeded(query: searchText)
    }
    
    fileprivate func cancelSearchTimer() {
        if timer != nil, timer!.isValid {
            timer?.invalidate()
            timer = nil
        }
    }
    
    fileprivate func searchIfNeeded(query: String?) {
        cancelSearchTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: false, block: { [weak self] (_) in
            guard let self = self else { return }
            self.search(query: query)
        })
    }
    
    fileprivate func search(query: String?) {
        guard let searchText = query else { return }
        dataSource?.startQuery(with: searchText)
    }
}

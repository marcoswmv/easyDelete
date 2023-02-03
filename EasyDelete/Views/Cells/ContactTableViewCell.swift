//
//  ContactTableViewCell.swift
//  EasyDelete
//
//  Created by Marcos Vicente on 31/01/23.
//

import UIKit

class ContactTableViewCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

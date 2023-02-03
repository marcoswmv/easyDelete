//
//  DeletedContactTableViewCell.swift
//  EasyDelete
//
//  Created by Marcos Vicente on 03/02/23.
//

import UIKit

class DeletedContactTableViewCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

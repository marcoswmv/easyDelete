//
//  DeletedContactTableViewCell.swift
//  EasyDelete
//
//  Created by Marcos Vicente on 03/02/23.
//

import UIKit
import SnapKit

class DeletedContactTableViewCell: UITableViewCell {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private lazy var detailLabel: UILabel = {
        let label = UILabel()
        label.font = .italicSystemFont(ofSize: 12)
        label.textColor = .gray
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func addSubviews() {
        contentView.addSubviews([titleLabel,
                                 subtitleLabel,
                                 detailLabel])
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20.0)
            make.top.equalToSuperview().offset(7.33)
            make.trailing.equalTo(detailLabel.snp.leading).offset(-10.0)
            make.bottom.equalTo(subtitleLabel.snp.top).offset(-2.67)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20.0)
            make.trailing.equalTo(detailLabel.snp.leading).offset(-10.0)
            make.bottom.equalToSuperview().offset(-7.33)
        }
        
        detailLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-10.0)
            make.centerY.equalToSuperview()
            make.width.equalTo(contentView.bounds.width / 4 - 10.0)
        }
    }
    
    func fill(with viewModel: ContactCellViewModel) {
        titleLabel.text = viewModel.name
        
        subtitleLabel.isHidden = viewModel.phoneNumbers.isEmpty
        subtitleLabel.text = viewModel.phoneNumbers.joined(separator: ", ")
        
        if let daysCount = Calendar.current.dateComponents([.day],
                                                           from: viewModel.deletionDate,
                                                           to: Date()).day {
            let remainingDays = 30 - daysCount
            if remainingDays > 0 {
                detailLabel.text = "\(abs(remainingDays)) day\(remainingDays > 1 ? "s" : "") left"
            } else {
                viewModel.handleExpiration?(viewModel.identifier)
            }
        }
        
        if viewModel.phoneNumbers.isEmpty {
            titleLabel.snp.remakeConstraints { remake in
                remake.leading.equalToSuperview().offset(20.0)
                remake.top.equalToSuperview().offset(13.0)
                remake.trailing.equalTo(detailLabel.snp.leading).offset(-10.0)
                remake.bottom.equalToSuperview().offset(-13.0)
            }
        } else {
            titleLabel.snp.remakeConstraints { remake in
                remake.leading.equalToSuperview().offset(20.0)
                remake.top.equalToSuperview().offset(7.33)
                remake.trailing.equalTo(detailLabel.snp.leading).offset(-10.0)
                remake.bottom.equalTo(subtitleLabel.snp.top).offset(-2.67)
            }
        }
    }
}

//
//  MenuTableViewCell.swift
//  Daily Tasks
//
//  Created by Phương Anh Tuấn on 24/06/2021.
//

import UIKit

class MenuTableViewCell: UITableViewCell {
    
    var cellImageView = UIImageView()
    var cellLabel = UILabel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cellImageView.translatesAutoresizingMaskIntoConstraints = false
        cellImageView.contentMode = .scaleAspectFit
        cellImageView.tintColor = .systemBlue
        contentView.addSubview(cellImageView)
        
        cellLabel.translatesAutoresizingMaskIntoConstraints = false
        cellLabel.font = UIFont.systemFont(ofSize: 16)
        contentView.addSubview(cellLabel)
        
        NSLayoutConstraint.activate([
            cellImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            cellImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cellImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cellImageView.widthAnchor.constraint(equalToConstant: 24),
            
            cellLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            cellLabel.leadingAnchor.constraint(equalTo: cellImageView.trailingAnchor, constant: 16),
        ])
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

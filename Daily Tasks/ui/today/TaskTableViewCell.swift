//
//  TaskTableViewCell.swift
//  Daily Tasks
//
//  Created by Phương Anh Tuấn on 23/06/2021.
//

import UIKit

class TaskTableViewCell: UITableViewCell {
    
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelDesc: UILabel!
    @IBOutlet weak var btnStatus: UIButton!
    @IBOutlet weak var imagePriority: UIImageView!
    
    var itemIndex = 0
    var itemSection = -1
    var statusChangeListener: ((Int) -> ())?
    var statusChangeListenerInSection : ((Int, Int) -> ())?
    
    private var isDone = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            contentView.backgroundColor = #colorLiteral(red: 0.7108142972, green: 0.7141059041, blue: 0.7221444845, alpha: 0.525196606)
        } else {
            contentView.backgroundColor = .secondarySystemGroupedBackground
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted {
            contentView.backgroundColor = #colorLiteral(red: 0.7108142972, green: 0.7141059041, blue: 0.7221444845, alpha: 0.525196606)
        } else {
            contentView.backgroundColor = .secondarySystemGroupedBackground
        }
    }
    
    func renderData(task: TaskEntity, canUpdate: Bool = true) {
        labelTitle.text = task.value(forKey: "title") as? String
        labelDesc.text = task.value(forKey: "taskDesc") as? String
        isDone = Int(task.value(forKey: "status") as? Int16 ?? 0)
        let priority = task.value(forKey: "priority") as? Int16 ?? 1
        updateStatus()
        switch priority {
        case 1:
            imagePriority.image = UIImage(named: "ic_p_1")
        case 2:
            imagePriority.image = UIImage(named: "ic_p_2")
        case 3:
            imagePriority.image = UIImage(named: "ic_p_3")
        default:
            imagePriority.image = UIImage(named: "ic_p_1")
        }
        if canUpdate {
            btnStatus.addTarget(self, action: #selector(btnStatusClicked(_:)), for: .touchUpInside)
        }
    }
    
    private func updateStatus() {
        if isDone == 0 {
            btnStatus.setImage(UIImage(named: "ic_uncheck"), for: .normal)
        } else {
            btnStatus.setImage(UIImage(named: "ic_check"), for: .normal)
        }
    }
    
    @objc func btnStatusClicked(_ sender: Any) {
        if (isDone != 0) {
            isDone = 0
        } else {
            isDone = 1
        }
        updateStatus()
        if itemSection == -1 {
            statusChangeListener?(itemIndex)
        } else {
            statusChangeListenerInSection?(itemSection, itemIndex)
        }
    }
}

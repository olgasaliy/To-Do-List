//
//  DueDatePickerCell.swift
//  To-Do List
//
//  Created by Olha Salii on 23.09.2024.
//

import UIKit

class DueDateToggleCell: UITableViewCell, InputChangeHandlingCell {
    
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var dueDateSwitch: UISwitch!
    
    weak var delegate: InputHandlingCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        dueDateLabel.text = "Due Date"
        dueDateSwitch.isOn = false
        
        dueDateSwitch.addTarget(self, action: #selector(switchToggled), for: .valueChanged)
    }
    
    @objc func switchToggled() {
        delegate?.inputDidChange(in: self, newValue: dueDateSwitch.isOn)
    }
    
    func configure(with value: Bool) {
        dueDateSwitch.isOn = value
    }
}

extension DueDateToggleCell: ToDoItemConfigurable {
    
    func configure(with item: ToDoItem) {
        configure(with: item.dueDate != nil)
    }
    
}

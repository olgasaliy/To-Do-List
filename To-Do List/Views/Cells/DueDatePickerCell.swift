//
//  DueDatePickerCell.swift
//  To-Do List
//
//  Created by Olha Salii on 30.09.2024.
//

import UIKit

class DueDatePickerCell: UITableViewCell, InputChangeHandlingCell {
    
    @IBOutlet weak var dueDatePicker: UIDatePicker!
    
    weak var delegate: InputHandlingCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        dueDatePicker.addTarget(self, action: #selector(datePickerDidChange), for: .valueChanged)
        dueDatePicker.preferredDatePickerStyle = .inline
        dueDatePicker.datePickerMode = .date
        dueDatePicker.minimumDate = Date()
    }
    
    @objc func datePickerDidChange() {
        delegate?.inputDidChange(in: self, newValue: dueDatePicker.date)
    }
    
    func configure(with date: Date?) {
        dueDatePicker.minimumDate = nil // no minimum date needed while showing selected date
        if let date = date {
            dueDatePicker.date = date
        }
    }
}

extension DueDatePickerCell: ToDoItemConfigurable {
    
    func configure(with item: ToDoItem) {
        configure(with: item.dueDate)
    }
    
}

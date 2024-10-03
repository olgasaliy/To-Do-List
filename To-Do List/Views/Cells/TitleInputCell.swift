//
//  TitleInputCell.swift
//  To-Do List
//
//  Created by Olha Salii on 23.09.2024.
//

import UIKit

class TitleInputCell: UITableViewCell, InputChangeHandlingCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    
    weak var delegate: InputHandlingCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.text = "Title"
        titleTextField.placeholder = "Enter title..."
        
        titleTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    @objc func textFieldDidChange() {
        delegate?.inputDidChange(in: self, newValue: titleTextField.text ?? "")
    }
    
    func configure(with title: String) {
        titleTextField.text = title
    }
}

extension TitleInputCell: ToDoItemConfigurable {
    
    func configure(with item: ToDoItem) {
        configure(with: item.title)
    }
    
}

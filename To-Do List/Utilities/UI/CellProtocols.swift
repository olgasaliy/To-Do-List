//
//  InputChangeHandlingCell.swift
//  To-Do List
//
//  Created by Olha Salii on 25.09.2024.
//

import UIKit

protocol InputChangeHandlingCell {
    var delegate: InputHandlingCellDelegate? { get set }
}

protocol InputHandlingCellDelegate: AnyObject {
    func inputDidChange(in cell: UITableViewCell, newValue: Any)
}

protocol ToDoItemConfigurable {
    func configure(with item: ToDoItem)
}

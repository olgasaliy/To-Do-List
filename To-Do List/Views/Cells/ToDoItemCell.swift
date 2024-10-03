//
//  ToDoItemCell.swift
//  To-Do List
//
//  Created by Olha Salii on 26.09.2024.
//

import UIKit

class ToDoItemCell: UITableViewCell {

    @IBOutlet weak var priorityLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dueDateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        priorityLabel.text = nil
        titleLabel.text = nil
        dueDateLabel.text = nil
        dueDateLabel.attributedText = nil
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        dueDateLabel.attributedText = nil
    }
    
    func configure(with toDoItem: ToDoItem) {
        titleLabel.text = toDoItem.title
        if let dueDate = toDoItem.dueDate {
            configureDueDateLabel(for: dueDate)
        }
        priorityLabel.attributedText = TaskPriority(rawValue: Int(toDoItem.priority))?.shortDisplayedTitle
    }

    private func configureDueDateLabel(for date: Date) {
        let dueDateText = date.formatted(date: .numeric, time: .omitted)
        let fullText = "Due: \(dueDateText)"
        let boldRange = (fullText as NSString).range(of: dueDateText)
        let attributedText = NSMutableAttributedString(string: fullText)
        attributedText.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 15), range: boldRange)
        dueDateLabel.attributedText = attributedText
        dueDateLabel.textColor = .gray
    }
}

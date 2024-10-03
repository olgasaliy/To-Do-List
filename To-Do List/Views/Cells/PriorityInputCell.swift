//
//  PriorityInputCell.swift
//  To-Do List
//
//  Created by Olha Salii on 23.09.2024.
//

import UIKit

enum TaskPriority: Int, CaseIterable {
    case low = 3
    case medium = 2
    case high = 1
    
    var title: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        }
    }
    
    var shortDisplayedTitle: NSAttributedString {
        switch self {
        case .low:
            return NSAttributedString()
        case .medium:
            return NSAttributedString(string: "!", attributes: [.foregroundColor: UIColor.red])
        case .high:
            return NSAttributedString(string: "!!", attributes: [.foregroundColor: UIColor.red])
        }
    }
    
    // Map from UISegmentedControl index to TaskPriority
        static func fromSegmentIndex(_ index: Int) -> TaskPriority {
            switch index {
            case 0: return .high
            case 1: return .medium
            case 2: return .low
            default: return .low  // Default to low if index is out of bounds
            }
        }

        // Map from TaskPriority to UISegmentedControl index
        func toSegmentIndex() -> Int {
            switch self {
            case .high: return 0
            case .medium: return 1
            case .low: return 2
            }
        }
}

class PriorityInputCell: UITableViewCell, InputChangeHandlingCell {
    @IBOutlet weak var priorityLabel: UILabel!
    @IBOutlet weak var prioritySegmentControl: UISegmentedControl!

    weak var delegate: InputHandlingCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        priorityLabel.text = "Priority"
        
        prioritySegmentControl.removeAllSegments()
        TaskPriority.allCases.forEach { prioritySegmentControl.insertSegment(withTitle: $0.title, at: 0, animated: false) }
        prioritySegmentControl.addTarget(self, action: #selector(priorityDidChange), for: .valueChanged)
    }
    
    @objc func priorityDidChange() {
        delegate?.inputDidChange(in: self, newValue: TaskPriority.fromSegmentIndex(prioritySegmentControl.selectedSegmentIndex)) //have to increase number in order to relate to TaskPriority model
    }
    
    func configure(with taskPriority: TaskPriority) {
        prioritySegmentControl.selectedSegmentIndex = taskPriority.toSegmentIndex()
    }
}

extension PriorityInputCell: ToDoItemConfigurable {
    
    func configure(with item: ToDoItem) {
        configure(with: item.taskPriority)
    }
    
}

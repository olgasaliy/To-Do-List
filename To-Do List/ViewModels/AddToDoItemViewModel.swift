//
//  AddToDoItem.swift
//  To-Do List
//
//  Created by Olha Salii on 23.09.2024.
//

import Foundation
import CoreData

enum DisplayMode: Equatable {
    case edit
    case add
}

enum AddTaskCellTypeIdentifiers: String, CaseIterable {
    case title = "TitleInputCell"
    case dueDateToggle = "DueDateToggleCell"  // Toggle for showing/hiding the due date picker
    case dueDatePicker = "DueDatePickerCell"  // Actual date picker
    case priority = "PriorityInputCell"
    
    var title: String {
        switch self {
        case .title: return "Title"
        case .dueDateToggle: return "Due Date"
        case .dueDatePicker: return ""
        case .priority: return "Priority"
        }
    }
}

protocol AddToDoItemViewModelDelegate: AnyObject {
    func didUpdateDatePickerVisibility(isOn: Bool)
    func didMakeAnyChanges()
}

class AddToDoItemViewModel {
    var displayMode: DisplayMode
    var toDoItem: ToDoItem
    
    private let context: NSManagedObjectContext
    private var isDatePickerVisible: Bool = false
    
    weak var delegate: (ErrorHandling & AddToDoItemViewModelDelegate)?
    
    // This array defines the order and type of cells to display
    var cellTypes: [AddTaskCellTypeIdentifiers] {
           if isDatePickerVisible {
               return [.title, .dueDateToggle, .dueDatePicker, .priority]  // Show the date picker
           } else {
               return [.title, .dueDateToggle, .priority]  // Hide the date picker
           }
       }
    
    init(with context: NSManagedObjectContext) {
        self.context = context
        self.toDoItem = ToDoItem(context: context)
        displayMode = .add
    }
    
    init(with context: NSManagedObjectContext, task: ToDoItem) {
        self.context = context
        self.toDoItem = task
        
        if task.dueDate != nil {
            isDatePickerVisible = true
        }
        displayMode = .edit
    }
    
    func handleCellInputChange(for indexPath: IndexPath, with value: Any?) {
        switch cellTypes[indexPath.row] {
        case .title:
            toDoItem.title = value as? String ?? ""
        case .dueDatePicker:
            toDoItem.dueDate = value as? Date
        case .priority:
            if let priority = value as? TaskPriority {
                toDoItem.taskPriority = priority
            }
        case .dueDateToggle:
            toggleDatePickerVisibility()
        }
        //notify VC about changes so that it'll unblock Save button
        delegate?.didMakeAnyChanges()
    }
    
    func saveToDoItem(completionHandler: () -> Void) {
        guard validateAllInputs() else { return }
        
        do {
            try context.save()
            completionHandler()
        } catch {
            delegate?.displayError(error, with: "Failed to add new task")
        }
    }
    
    private func toggleDatePickerVisibility() {
        // If date picker is currently visible and now being hidden, reset the due date
        if isDatePickerVisible {
            toDoItem.dueDate = nil
        } else { // otherwise set the default displayed date to toDoItem
            toDoItem.dueDate = .now
        }
        
        isDatePickerVisible.toggle()
        delegate?.didUpdateDatePickerVisibility(isOn: isDatePickerVisible)
    }
    
    private func validateAllInputs() -> Bool {
        if toDoItem.title.isEmpty {
            let errorDescription = "Please enter a title for your task"
            delegate?.displayError(nil, with: errorDescription)
            return false
        }
        if toDoItem.priority == 0 {
            let errorDescription = "Please select a priority for your task"
            delegate?.displayError(nil, with: errorDescription)
            return false
        }
        if let dueDate = toDoItem.dueDate, dueDate < Calendar.current.startOfDay(for: .now) {
            let errorDescription = "Please select a future due date for your task"
            delegate?.displayError(nil, with: errorDescription)
            return false
        }
        
        return true
    }
}

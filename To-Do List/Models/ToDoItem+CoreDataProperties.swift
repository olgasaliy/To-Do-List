//
//  ToDoItem+CoreDataProperties.swift
//  To-Do List
//
//  Created by Olha Salii on 19.09.2024.
//
//

import Foundation
import CoreData

extension ToDoItem {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ToDoItem> {
        return NSFetchRequest<ToDoItem>(entityName: "ToDoItem")
    }

    @NSManaged public var dueDate: Date?
    @NSManaged public var isCompleted: Bool
    @NSManaged public var priority: Int16
    @NSManaged public var title: String

    var taskPriority: TaskPriority {
        get {
            return TaskPriority(rawValue: Int(priority)) ?? .low  // Default to .low if invalid value
        }
        set {
            priority = Int16(newValue.rawValue)  // Store the raw value of TaskPriority
        }
    }
}

extension ToDoItem : Identifiable {

}

//
//  ToDoManager.swift
//  To-Do List
//
//  Created by Olha Salii on 20.09.2024.
//

import CoreData
import Foundation

protocol ToDoManagerDelegate: AnyObject {
    func didUpdateToDoItems()
}

class ToDoListViewModel {
    weak var delegate: (ToDoManagerDelegate & ErrorHandling)?
    
    private(set) var tasks: [ToDoItem] = []
    private(set) var context: NSManagedObjectContext
    
    init(with context: NSManagedObjectContext) {
        self.context = context
    }
    
    func fetchToDoItems() {
        let fetchRequest: NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest()
        let sortDescriptor = NSSortDescriptor(keyPath: \ToDoItem.priority, ascending: true)
//        let predicate = NSPredicate(format: "isCompleted == %@", NSNumber(value: false))
//        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            tasks = try context.fetch(fetchRequest)
            delegate?.didUpdateToDoItems()
        } catch {
            delegate?.displayError(error, with: "Failed to fetch tasks")   
        }
    }
    
    func removeItem(at index: Int, completionWithSuccess: (Bool) -> Void) {
        guard index >= 0 && index < tasks.count else {
            completionWithSuccess(false)
            delegate?.displayError(nil, with: "Index \(index) is out of bounds")
            return
        }
        
        let itemToRemove = tasks[index]
        context.delete(itemToRemove)  // Remove from Core Data
        
        do {
            try context.save()
            tasks.remove(at: index)
            completionWithSuccess(true)
        } catch {
            completionWithSuccess(false)
            delegate?.displayError(error, with: "Failed to remove item")
        }
    }
    
    func completeToDoItem(at index: Int, completionWithSuccess: (Bool) -> Void) {
        guard index >= 0 && index < tasks.count else {
            completionWithSuccess(false)
            delegate?.displayError(nil, with: "Index \(index) is out of bounds")
            return
        }
        
        let itemToComplete = tasks[index]
        guard !itemToComplete.isCompleted else {
            completionWithSuccess(false)
            delegate?.displayError(nil, with: "To Do Item is already completed.")
            return
        }
        
        itemToComplete.isCompleted = true
        
        do {
            try context.save()
            tasks.remove(at: index)
            completionWithSuccess(true)
        } catch {
            completionWithSuccess(false)
            delegate?.displayError(error, with: "Failed to complete the item")
        }
    }
    
}

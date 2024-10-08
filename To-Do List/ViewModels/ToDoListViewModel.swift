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
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            let fetchRequest: NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest()
            let sortDescriptor = NSSortDescriptor(keyPath: \ToDoItem.priority, ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptor]
            
            do {
                let fetchedTasks = try context.fetch(fetchRequest)
                DispatchQueue.main.async {
                    self.tasks = fetchedTasks
                    self.delegate?.didUpdateToDoItems()
                }
            } catch {
                delegate?.displayError(error, with: "Failed to fetch tasks")
            }
        }
    }
    
    func removeItem(at index: Int, completionWithSuccess: (Bool) -> Void) {
        guard index >= 0 && index < tasks.count else {
            delegate?.displayError(nil, with: "Index \(index) is out of bounds")
            completionWithSuccess(false)
            return
        }
        
        let itemToRemove = tasks[index]
        context.delete(itemToRemove)  // Remove from Core Data
        
        do {
            try context.save()
            tasks.remove(at: index)
            completionWithSuccess(true)
        } catch {
            delegate?.displayError(error, with: "Failed to remove item")
            completionWithSuccess(false)
        }
    }
    
    func completeToDoItem(at index: Int, completionWithSuccess: (Bool) -> Void) {
        guard index >= 0 && index < tasks.count else {
            delegate?.displayError(nil, with: "Index \(index) is out of bounds")
            completionWithSuccess(false)
            return
        }
        
        let itemToComplete = tasks[index]
        guard !itemToComplete.isCompleted else {
            delegate?.displayError(nil, with: "To Do Item is already completed.")
            completionWithSuccess(false)
            return
        }
        
        itemToComplete.isCompleted = true
        
        do {
            try context.save()
            tasks.remove(at: index)
            completionWithSuccess(true)
        } catch {
            delegate?.displayError(error, with: "Failed to complete the item")
            completionWithSuccess(false)
        }
    }
    
}

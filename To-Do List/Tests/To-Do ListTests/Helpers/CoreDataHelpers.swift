//
//  CoreDataHelpers.swift
//  To-Do List
//
//  Created by Olha Salii on 03.10.2024.
//
import CoreData

// Helpers
extension NSPersistentContainer {

    static func setUpInMemoryManagedObjectContext() -> NSManagedObjectContext {
        let persistentContainer = NSPersistentContainer(name: "To_Do_List")

        // Set up the in-memory store description
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        
        // Set the in-memory store description
        persistentContainer.persistentStoreDescriptions = [description]

        // Load the persistent stores
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            if let error = error {
                fatalError("Failed to load in-memory Core Data store: \(error)")
            }
        }

        return persistentContainer.viewContext
    }
}

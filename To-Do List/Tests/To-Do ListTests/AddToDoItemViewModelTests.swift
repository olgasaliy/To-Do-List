//
//  AddToDoItemViewModelTests.swift
//  To-Do ListTests
//
//  Created by Olha Salii on 03.10.2024.
//

import XCTest
import CoreData
@testable import To_Do_List

class AddToDoItemMockDelegate: AddToDoItemViewModelDelegate, ErrorHandling {

    var didUpdateDatePickerVisibilityCalled = false
    var didMakeAnyChangesCalled = false
    var displayErrorCalled = false

    func didUpdateDatePickerVisibility(isOn: Bool) {
        didUpdateDatePickerVisibilityCalled = true
    }
    
    func didMakeAnyChanges() {
        didMakeAnyChangesCalled = true
    }
    
    func displayError(_ error: Error?, with description: String) {
        displayErrorCalled = true
    }
}

final class AddToDoItemViewModelTests: XCTestCase {

    var viewModel: AddToDoItemViewModel!
    var mockContext: NSManagedObjectContext!
    var mockDelegate: AddToDoItemMockDelegate!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        mockContext = NSPersistentContainer.setUpInMemoryManagedObjectContext()
        mockDelegate = AddToDoItemMockDelegate()
    }

    override func tearDownWithError() throws {
        mockContext = nil
        viewModel = nil
        mockDelegate = nil
        try super.tearDownWithError()
    }

    func testInitWithAddMode() {
        viewModel = AddToDoItemViewModel(with: mockContext)
        
        XCTAssertEqual(viewModel.displayMode, .add)
        XCTAssertNotNil(viewModel.toDoItem)
        XCTAssertEqual(viewModel.toDoItem.title, "")
    }
    
    func testInitWithEditMode() {
        let task1 = ToDoItem(context: mockContext)
        task1.title = "Test1"
        task1.isCompleted = false
        task1.taskPriority = .high
        try? mockContext.save()
        
        viewModel = AddToDoItemViewModel(with: mockContext, task: task1)
        
        XCTAssertEqual(viewModel.displayMode, .edit)
        XCTAssertEqual(viewModel.toDoItem, task1)
        
        task1.dueDate = .now
        try? mockContext.save()
        
        viewModel = AddToDoItemViewModel(with: mockContext, task: task1)
        XCTAssertTrue(viewModel.cellTypes.contains(.dueDatePicker))
    }
    
    func testHandleTitleInputChange_AddMode() {
        viewModel = AddToDoItemViewModel(with: mockContext)
        viewModel.delegate = mockDelegate
        XCTAssertEqual(viewModel.cellTypes.count, 3)
        
        //Title
        viewModel.handleCellInputChange(for: IndexPath(row: 0, section: 0),
                                        with: "Test")
        XCTAssertEqual(viewModel.toDoItem.title, "Test")
        XCTAssertTrue(mockDelegate.didMakeAnyChangesCalled)
        
        //Priority
        viewModel.handleCellInputChange(for: IndexPath(row: 2, section: 0),
                                        with: TaskPriority.high)
        XCTAssertEqual(viewModel.toDoItem.taskPriority, TaskPriority.high)
        XCTAssertEqual(viewModel.toDoItem.priority, Int16(TaskPriority.high.rawValue))
        XCTAssertTrue(mockDelegate.didMakeAnyChangesCalled)
        
        //DueDateToggle is on
        viewModel.handleCellInputChange(for: IndexPath(row: 1, section: 0),
                                        with: nil)
        XCTAssertNotNil(viewModel.toDoItem.dueDate)
        XCTAssertEqual(viewModel.cellTypes.count, 4)
        XCTAssertTrue(mockDelegate.didMakeAnyChangesCalled)
        XCTAssertTrue(mockDelegate.didUpdateDatePickerVisibilityCalled)
        
        //DueDatePicker
        let date: Date = .now
        viewModel.handleCellInputChange(for: IndexPath(row: 2, section: 0),
                                        with: date)
        XCTAssertNotNil(viewModel.toDoItem.dueDate)
        if let dueDate = viewModel.toDoItem.dueDate {
            XCTAssertEqual(dueDate.timeIntervalSinceReferenceDate, date.timeIntervalSinceReferenceDate, accuracy: 0.001)
        }
        
        //DueDateToggle is off
        viewModel.handleCellInputChange(for: IndexPath(row: 1, section: 0),
                                        with: nil)
        XCTAssertNil(viewModel.toDoItem.dueDate)
        XCTAssertEqual(viewModel.cellTypes.count, 3)
        XCTAssertTrue(mockDelegate.didMakeAnyChangesCalled)
        XCTAssertTrue(mockDelegate.didUpdateDatePickerVisibilityCalled)
    }
    
    func testSaveToDoItem_Success_AddMode() {
        viewModel = AddToDoItemViewModel(with: mockContext)
        viewModel.delegate = mockDelegate
        
        viewModel.handleCellInputChange(for: IndexPath(row: 0, section: 0),
                                        with: "Test")
        viewModel.handleCellInputChange(for: IndexPath(row: 2, section: 0),
                                        with: TaskPriority.high)
        
        viewModel.saveToDoItem {}
        XCTAssertFalse(mockDelegate.displayErrorCalled)
        let fetchRequest: NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest()
        let tasks = try? mockContext.fetch(fetchRequest)
        XCTAssertNotNil(tasks)
        if let tasks = tasks {
            XCTAssertEqual(tasks.count, 1)
        }
    }
    
    func testSaveToDoItem_Failure_EmptyPriority() {
        viewModel = AddToDoItemViewModel(with: mockContext)
        viewModel.delegate = mockDelegate
        
        viewModel.handleCellInputChange(for: IndexPath(row: 0, section: 0),
                                        with: "Test")
        
        viewModel.saveToDoItem {}
        XCTAssertTrue(mockDelegate.displayErrorCalled)
    }
    
    func testSaveToDoItem_Failure_EmptyTitle() {
        viewModel = AddToDoItemViewModel(with: mockContext)
        viewModel.delegate = mockDelegate
        
        viewModel.handleCellInputChange(for: IndexPath(row: 2, section: 0),
                                        with: TaskPriority.high)
        
        viewModel.saveToDoItem {}
        XCTAssertTrue(mockDelegate.displayErrorCalled)
    }
    
    func testSaveToDoItem_Failure_DateInPast() {
        viewModel = AddToDoItemViewModel(with: mockContext)
        viewModel.delegate = mockDelegate
        
        viewModel.handleCellInputChange(for: IndexPath(row: 0, section: 0),
                                        with: "Test")
        viewModel.handleCellInputChange(for: IndexPath(row: 2, section: 0),
                                        with: TaskPriority.high)
        viewModel.handleCellInputChange(for: IndexPath(row: 1, section: 0),
                                        with: nil)
        viewModel.handleCellInputChange(for: IndexPath(row: 2, section: 0),
                                        with: Date.distantPast)
        
        viewModel.saveToDoItem {}
        XCTAssertTrue(mockDelegate.displayErrorCalled)
    }
    
    func testSaveToDoItem_Success_EditMode() {
        let task1 = ToDoItem(context: mockContext)
        task1.title = "Test1"
        task1.isCompleted = false
        task1.taskPriority = .high
        try? mockContext.save()
        
        viewModel = AddToDoItemViewModel(with: mockContext, task: task1)
        viewModel.delegate = mockDelegate
        
        viewModel.handleCellInputChange(for: IndexPath(row: 0, section: 0),
                                        with: "Test1 Updated")
        viewModel.handleCellInputChange(for: IndexPath(row: 2, section: 0),
                                        with: TaskPriority.low)
        
        viewModel.saveToDoItem {}
        XCTAssertFalse(mockDelegate.displayErrorCalled)
        
        let fetchRequest: NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest()
        let tasks = try? mockContext.fetch(fetchRequest)
        XCTAssertNotNil(tasks)
        if let taskUpdated = tasks?.first {
            XCTAssertEqual(taskUpdated.title, "Test1 Updated")
            XCTAssertEqual(taskUpdated.taskPriority, TaskPriority.low)
        }
    }
    

}

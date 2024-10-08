//
//  ToDoListViewModelTests.swift
//  To-Do ListTests
//
//  Created by Olha Salii on 03.10.2024.
//

import XCTest
import CoreData
@testable import To_Do_List

class MockToDoManagerDelegate: ToDoManagerDelegate, ErrorHandling {

    var didUpdateItemsCalled = false
    var displayErrorCalled = false

    func didUpdateToDoItems() {
        didUpdateItemsCalled = true
    }

    func displayError(_ error: Error?, with description: String) {
        displayErrorCalled = true
    }
}

final class ToDoListViewModelTests: XCTestCase {

    var viewModel: ToDoListViewModel!
    var mockContext: NSManagedObjectContext!
    var mockDelegate: MockToDoManagerDelegate!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        mockContext = NSPersistentContainer.setUpInMemoryManagedObjectContext()
        viewModel = ToDoListViewModel(with: mockContext)
        mockDelegate = MockToDoManagerDelegate()
        viewModel.delegate = mockDelegate
    }

    override func tearDownWithError() throws {
        viewModel = nil
        mockContext = nil
        mockDelegate = nil
        try super.tearDownWithError()
    }
    
    func testFetchToDoItems_Success() {
        let expectation = self.expectation(description: "FetchToDoItems completes")
        
        let task1 = ToDoItem(context: mockContext)
        task1.title = "Test1"
        task1.isCompleted = false
        task1.taskPriority = .high
        try? mockContext.save()
        
        viewModel.fetchToDoItems()
        
        // Wait for the asynchronous call to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Perform assertions after the async operation completes
            XCTAssertEqual(self.viewModel.tasks.count, 1)
            XCTAssertTrue(self.mockDelegate.didUpdateItemsCalled)
            
            // Fulfill the expectation
            expectation.fulfill()
        }
        
        // Wait for expectations with a timeout
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testRemoveItem_Success() {
        let expectation = self.expectation(description: "FetchToDoItems completes")

        let task1 = ToDoItem(context: mockContext)
        task1.title = "Test1"
        task1.isCompleted = false
        task1.taskPriority = .high
        try? mockContext.save()
        viewModel.fetchToDoItems()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.viewModel.removeItem(at: 0) { result in
                XCTAssertTrue(result)
                XCTAssertEqual(self.viewModel.tasks.count, 0)
                XCTAssertTrue(self.mockDelegate.didUpdateItemsCalled)
                
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
     }

    func testRemoveItem_Failure() {
        var removalSuccess = true
        viewModel.removeItem(at: 10) { success in
            removalSuccess = success
        }
        
        XCTAssertFalse(removalSuccess)
        XCTAssertTrue(mockDelegate.displayErrorCalled)
     }
    
    func testCompleteToDoItem_Success() {
        let expectation = self.expectation(description: "FetchToDoItems completes")
        
        let task1 = ToDoItem(context: mockContext)
        task1.title = "Test1"
        task1.isCompleted = false
        task1.taskPriority = .high
        try? mockContext.save()
        viewModel.fetchToDoItems()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.viewModel.completeToDoItem(at: 0) { success in
                XCTAssertTrue(success)
                XCTAssertTrue(task1.isCompleted)
                XCTAssertTrue(self.mockDelegate.didUpdateItemsCalled)
                
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testCompleteToDoItem_AlreadyCompleted() {
        let task1 = ToDoItem(context: mockContext)
        task1.title = "Test1"
        task1.isCompleted = true
        task1.taskPriority = .high
        try? mockContext.save()
        viewModel.fetchToDoItems()
        
        viewModel.completeToDoItem(at: 0) { success in
            XCTAssertFalse(success)
            XCTAssertTrue(mockDelegate.displayErrorCalled)
        }
    }
    
}


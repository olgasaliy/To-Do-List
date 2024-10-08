//
//  ToDoListViewControllerTests.swift
//  To-Do ListTests
//
//  Created by Olha Salii on 04.10.2024.
//

import XCTest
import CoreData
@testable import To_Do_List

class ToDoListViewModelMock: ToDoListViewModel {
    var fetchToDoItemsCalled = false
    var removeItemCalled = false
    var completeToDoItemCalled = false
    
    override func fetchToDoItems() {
        super.fetchToDoItems()
        fetchToDoItemsCalled = true
    }
    
    override func removeItem(at index: Int, completionWithSuccess: (Bool) -> Void) {
        removeItemCalled = true
        completionWithSuccess(true)
    }
    
    override func completeToDoItem(at index: Int, completionWithSuccess: (Bool) -> Void) {
        completeToDoItemCalled = true
        completionWithSuccess(true)
    }
}

final class ToDoListViewControllerTests: XCTestCase {
    
    var viewController: ToDoListViewController!
    var viewModel: ToDoListViewModelMock!
    var context: NSManagedObjectContext!
    var mockTableView: UITableView!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        context = NSPersistentContainer.setUpInMemoryManagedObjectContext()
        viewModel = ToDoListViewModelMock(with: context)
        viewController = ToDoListViewController()
        viewController.viewModel = viewModel
        // Force the view to load
        _ = viewController.view
        
        mockTableView = viewController.tableView
    }

    override func tearDownWithError() throws {
        context = nil
        viewModel = nil
        viewController = nil
        mockTableView = nil
        try super.tearDownWithError()
    }
    
    func testViewDidLoad() {
        XCTAssertNotNil(viewController.viewModel)
        XCTAssertTrue(viewModel.delegate === viewController)
        XCTAssertTrue(viewModel.fetchToDoItemsCalled)
    }

    func testTableViewDataSource() {
        let expectation = self.expectation(description: "Fetching is completed")
        
        let mockTask1 = ToDoItem(context: context)
        mockTask1.title = "Task 1"
        let mockTask2 = ToDoItem(context: context)
        mockTask2.title = "Task 2"
        try? context.save()
        viewModel.fetchToDoItems()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.mockTableView.reloadData()
            XCTAssertEqual(self.viewController.tableView.numberOfRows(inSection: 0), 2)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testSwipeToDeleteAction() {
        let mockTask1 = ToDoItem(context: context)
        mockTask1.title = "Task 1"
        try? context.save()
        viewModel.fetchToDoItems()
        mockTableView.reloadData()
        
        // Trigger the swipe action
        let swipeActions = viewController.tableView(viewController.tableView,
                                                    trailingSwipeActionsConfigurationForRowAt: IndexPath(row: 0, section: 0))
        
        // Assert that the swipe action is available
        XCTAssertNotNil(swipeActions)
        
        // Simulate tapping the delete action
        if let deleteAction = swipeActions?.actions.first {
            XCTAssertEqual(deleteAction.style, .destructive)
            XCTAssertEqual(deleteAction.title, "Delete")
        }
    }
    
    func testSwipeToMarkCompletedAction() {
        let mockTask1 = ToDoItem(context: context)
        mockTask1.title = "Task 1"
        try? context.save()
        viewModel.fetchToDoItems()
        mockTableView.reloadData()
        
        // Trigger the swipe action
        let swipeActions = viewController.tableView(viewController.tableView,
                                                    leadingSwipeActionsConfigurationForRowAt: IndexPath(row: 0, section: 0))
        
        // Assert that the swipe action is available
        XCTAssertNotNil(swipeActions)
        
        // Simulate tapping the delete action
        if let markAction = swipeActions?.actions.first {
            XCTAssertEqual(markAction.style, .normal)
            XCTAssertEqual(markAction.title, "Complete")
        }
    }
    
    func testSegueToAddToDoItem() {
        let segue = UIStoryboardSegue(identifier: ToDoListViewController.SegueIdentifier.showAddToDoItem.rawValue,
                                      source: viewController,
                                      destination: UINavigationController())
        
        // Perform segue
        viewController.prepare(for: segue, sender: nil)
        
        // Assert that the AddToDoItemViewController is set correctly
        if let navController = segue.destination as? UINavigationController,
           let addToDoItemVC = navController.topViewController as? AddToDoItemViewController {
            XCTAssertNotNil(addToDoItemVC.viewModel)
            XCTAssertTrue(addToDoItemVC.viewModel.displayMode == .add)
            XCTAssertTrue(addToDoItemVC.delegate === viewController)
        }
    }
    
    func testSegueToShowTaskDetail() {
        let segue = UIStoryboardSegue(identifier: ToDoListViewController.SegueIdentifier.showTaskDetail.rawValue,
                                      source: viewController,
                                      destination: UINavigationController())
        
        // Perform segue
        viewController.prepare(for: segue, sender: nil)
        
        // Assert that the AddToDoItemViewController is set correctly
        if let detailsItemVC = segue.destination as? AddToDoItemViewController {
            XCTAssertNotNil(detailsItemVC.viewModel)
            XCTAssertTrue(detailsItemVC.viewModel.displayMode == .edit)
            XCTAssertTrue(detailsItemVC.delegate === viewController)
        }
    }

}

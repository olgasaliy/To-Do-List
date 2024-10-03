//
//  ToDoListViewController.swift
//  To-Do List
//
//  Created by Olha Salii on 20.09.2024.
//

import UIKit

class ToDoListViewController: UITableViewController, ErrorHandling {
    
    enum SegueIdentifier: String {
        case showAddToDoItem
        case showTaskDetail
        // Add other segue identifiers here as needed
    }
    
    var toDoManager: ToDoListViewModel!
    private var selectedItemIndex: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard toDoManager != nil else {
            fatalError("ToDoManager is not set")
        }
        
        toDoManager.delegate = self
        toDoManager.fetchToDoItems()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        toDoManager.tasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        let task = toDoManager.tasks[indexPath.row]
        if let toDoItemCell = cell as? ToDoItemCell {
            toDoItemCell.configure(with: task)
        } else {
            cell.textLabel?.text = task.title
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, view, completionHandler) in
            self?.toDoManager.removeItem(at: indexPath.row) { success in
                if success {
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                }
                
                completionHandler(success)
            }
        }
        
        deleteAction.backgroundColor = .red
        
        // Create a swipe actions configuration with the delete action
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [deleteAction])
        return swipeConfiguration
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let completeAction = UIContextualAction(style: .normal, title: "Complete") { [weak self] (action, view, completionHandler) in
            self?.toDoManager.completeToDoItem(at: indexPath.row) { [weak self] success in
                if success {
                    self?.animateCellBeforeRemoval(at: indexPath)
                }
                
                completionHandler(success)
            }
        }
        
        completeAction.backgroundColor = .systemBlue
        
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [completeAction])
        return swipeConfiguration
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedItemIndex = indexPath
        performSegue(withIdentifier: SegueIdentifier.showTaskDetail.rawValue, sender: self)  // Trigger the segue
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Use the enum to check the segue identifier
        guard let identifier = SegueIdentifier(rawValue: segue.identifier ?? "") else { return }

        switch identifier {
        case .showAddToDoItem:
            if let navController = segue.destination as? UINavigationController,
               let addToDoItemVC = navController.topViewController as? AddToDoItemViewController {
                addToDoItemVC.delegate = self
                addToDoItemVC.viewModel = AddToDoItemViewModel(with: toDoManager.context)
            }

        case .showTaskDetail:
            if let detailsItemVC = segue.destination as? AddToDoItemViewController,
               let selectedItemIndex = selectedItemIndex?.row {
                detailsItemVC.delegate = self
                detailsItemVC.viewModel = AddToDoItemViewModel(with: toDoManager.context,
                                                               task: toDoManager.tasks[selectedItemIndex])
                detailsItemVC.tableView.reloadData()
            }
        }
    }
    
    private func animateCellBeforeRemoval(at indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            UIView.animate(withDuration: 0.5, animations: {
                cell.alpha = 0.0
                cell.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }) { _ in
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
    }
    
}

extension ToDoListViewController: ToDoManagerDelegate {
    
    func didUpdateToDoItems() {
        tableView.reloadData()
    }
    
}

extension ToDoListViewController: AddToDoItemDelegate {
    
    func didAddNewToDoItem() {
        toDoManager.fetchToDoItems()
        tableView.reloadData()
    }
    
}

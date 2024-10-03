//
//  AddToDoItemViewController.swift
//  To-Do List
//
//  Created by Olha Salii on 23.09.2024.
//

import UIKit

protocol AddToDoItemDelegate: AnyObject {
    func didAddNewToDoItem()
}

class AddToDoItemViewController: UITableViewController, ErrorHandling {
    var viewModel: AddToDoItemViewModel!
    weak var delegate: AddToDoItemDelegate?
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        registerCells()
        saveButton.isEnabled = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpLeftBarButtonItem()
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        viewModel.saveToDoItem { [weak self] in
            self?.delegate?.didAddNewToDoItem()
            self?.cancelButtonTapped(sender)
        }
    }
    
    @objc func cancelButtonTapped(_ sender: Any) {
        switch viewModel.displayMode {
        case .add:
            dismiss(animated: true)
        case .edit:
            navigationController?.popViewController(animated: true)
        }
    }
    
    private func setUpLeftBarButtonItem() {
        if viewModel.displayMode == .add {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButtonTapped))
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return viewModel.cellTypes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: viewModel.cellTypes[indexPath.row].rawValue, for: indexPath)
        
        if var inputHandlingCell = cell as? InputChangeHandlingCell {
            inputHandlingCell.delegate = self
        }
        
        if let configurableCell = cell as? ToDoItemConfigurable,
           viewModel.displayMode == .edit {
            configurableCell.configure(with: viewModel.toDoItem)
        }
        return cell
    }
    
    private func registerCells() {
        AddTaskCellTypeIdentifiers.allCases.forEach {
            tableView.register(UINib(nibName: $0.rawValue, bundle: nil), forCellReuseIdentifier: $0.rawValue)
        }
    }

}

extension AddToDoItemViewController: AddToDoItemViewModelDelegate {
    
    func didUpdateDatePickerVisibility(isOn: Bool) {
        tableView.beginUpdates()
        
        if isOn {
            tableView.insertRows(at: [IndexPath(row: 2, section: 0)], with: .fade)
        } else {
            tableView.deleteRows(at: [IndexPath(row: 2, section: 0)], with: .fade)
        }
        
        tableView.endUpdates()
    }
    
    func didMakeAnyChanges() {
        saveButton.isEnabled = true
    }
}

extension AddToDoItemViewController: InputHandlingCellDelegate {
    
    func inputDidChange(in cell: UITableViewCell, newValue: Any) {
        if let indexPath = tableView.indexPath(for: cell) {
            viewModel.handleCellInputChange(for: indexPath, with: newValue)
        }
    }
    
}

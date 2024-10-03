//
//  Protocols.swift
//  To-Do List
//
//  Created by Olha Salii on 23.09.2024.
//

import UIKit

protocol ErrorHandling: AnyObject {
    func displayError(_ error: Error?, with description: String)
}

extension ErrorHandling where Self: UIViewController {
    func displayError(_ error: Error? = nil, with description: String) {
        var displayDescription: String = description
        if let error {
            displayDescription += "\n\(error.localizedDescription)"
        }
        
        let alert = UIAlertController(title: "Error",
                                      message: displayDescription,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK",
                                      style: .default,
                                      handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

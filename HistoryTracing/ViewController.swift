//
//  ViewController.swift
//  HistoryTracing
//
//  Created by Levy Cristian on 28/06/20.
//  Copyright © 2020 Levy Cristian. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    lazy var viewModel: MainViewModel = {
        let viewModel = MainViewModel()
        return viewModel
    }()

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        CoreDataManager.shared.fetchedResultsController.delegate = self
        NotificationCenter.default.addObserver(viewModel, selector: #selector(viewModel.preocessNotification(_:)), name: .NSPersistentStoreRemoteChange, object: nil)

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.viewModel.getData()
    }
    
    @IBAction func addElement(_ sender: UIBarButtonItem) {
        let item = Item(context: CoreDataManager.shared.getContext())
        item.title = UUID().uuidString
        CoreDataManager.shared.getContext().insert(item)
        CoreDataManager.shared.saveContext()
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = CoreDataManager.shared.fetchedResultsController.sections else {
          return 0
        }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView,
                     cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "basicCell",
                                                 for: indexPath)
        configureCell(cell, at: indexPath)
        return cell
    }
      
      func configureCell(_ cell: UITableViewCell, at indexPath: IndexPath) {
        
        /*get managed object from fetchResultController object*/
        let item = CoreDataManager.shared.fetchedResultsController.object(at: indexPath)
        // Configure Cell
        cell.textLabel?.text = item.title
      }

    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let sections = CoreDataManager.shared.fetchedResultsController.sections, let objects = sections[indexPath.section].objects as? [Item] else {
              return
            }
            CoreDataManager.shared.getContext().delete(objects[indexPath.row])
            CoreDataManager.shared.saveContext()
        }
    }
}

extension ViewController: NSFetchedResultsControllerDelegate{
  
  func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    tableView.beginUpdates()
  }
  
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    switch (type) {
    case .insert:
      if let indexPath = newIndexPath {
        tableView.insertRows(at: [indexPath], with: .fade)
      }
      break;
    case .delete:
      if let indexPath = indexPath {
        tableView.deleteRows(at: [indexPath], with: .fade)
      }
      break;
    case .update:
      if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) {
        configureCell(cell, at: indexPath)
      }
      break;
    case .move:
      if let indexPath = indexPath {
        tableView.deleteRows(at: [indexPath], with: .fade)
      }
      
      if let newIndexPath = newIndexPath {
        tableView.insertRows(at: [newIndexPath], with: .fade)
      }
        break;
    @unknown default:
        break;
    }
  }
  
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    tableView.endUpdates()
  }
}

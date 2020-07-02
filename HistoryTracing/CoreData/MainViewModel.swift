//
//  MainViewModel.swift
//  HistoryTracing
//
//  Created by Levy Cristian on 29/06/20.
//  Copyright © 2020 Levy Cristian. All rights reserved.
//

import Foundation

public class MainViewModel {
    
    public func getData() {
        do {
            try CoreDataManager.shared.fetchedResultsController.performFetch()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    @objc public func preocessNotification(_ notification: NSNotification) {
      CoreDataManager.shared.operationQueue.addOperation {
        let context = CoreDataManager.shared.getContext()
           context.performAndWait {
            CoreDataManager.shared.saveContext()
           }
       }
    }
}

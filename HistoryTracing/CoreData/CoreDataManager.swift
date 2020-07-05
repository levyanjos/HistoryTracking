//
//  CoreDataManager.swift
//  HistoryTracing
//
//  Created by Levy Cristian on 28/06/20.
//  Copyright © 2020 Levy Cristian. All rights reserved.
//

import Foundation
import CoreData

open class CoreDataManager {
    // MARK: - Core Data stack
    
    public static let shared = CoreDataManager()
    
    public lazy var fetchedResultsController: NSFetchedResultsController<Item> = {
        // Initialize Fetch Request
        //let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        /*Before you can do anything with Core Data, you need a managed object context. */
        let managedContext = CoreDataManager.shared.persistentContainer.viewContext
        
        /*As the name suggests, NSFetchRequest is the class responsible for fetching from Core Data.
         
         Initializing a fetch request with init(entityName:), fetches all objects of a particular entity. This is what you do here to fetch all Person entities.
         */
        let fetchRequest = NSFetchRequest<Item>(entityName: "Item")
        
        // Add Sort Descriptors
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Initialize Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController<Item>(fetchRequest: fetchRequest, managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        // Configure Fetched Results Controller
    //    fetchedResultsController.delegate = self
        
        return fetchedResultsController
      }()

    public lazy var persistentContainer: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: "HistoryTracing")
        
        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("No description found")
        }
        
        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        let remoteChangeKey = "NSPersistentStoreRemoteChangeNotificationOptionKey"
        description.setOption(true as NSNumber, forKey: remoteChangeKey)
        
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        try? container.viewContext.setQueryGenerationFrom(.current)

        container.viewContext.automaticallyMergesChangesFromParent = true
        
        return container
    }()

    // MARK: - Core Data Saving support
    
    public func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    public func getContext() -> NSManagedObjectContext {
        return self.persistentContainer.viewContext
    }
    
    private func getEntityDescription(entityName: String) -> NSEntityDescription? {
        let context = self.getContext()
        guard let description = NSEntityDescription.entity(forEntityName: entityName, in: context) else {return nil}
        return description
    }
}

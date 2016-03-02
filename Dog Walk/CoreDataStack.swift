//
//  CoreDataStack.swift
//  Dog Walk
//
//  Created by Michael Alford on 3/2/16.
//  Copyright © 2016 Razeware. All rights reserved.
//

import CoreData


class CoreDataStack {
    //name the model
    let modelName = "Maeby Walks"
    
    
    
    //Initialize managed context using MainQueueConcurrencyType
    //Your managed context isn’t very useful until you connect it to an NSPersistentStoreCoordinator. 
    //You do this by setting the managed context’s persistentStoreCoordinator property to stack’s store coordinator.
    lazy var context: NSManagedObjectContext = {
        
        var managedObjectContext = NSManagedObjectContext(
        concurrencyType: .MainQueueConcurrencyType)
        
        managedObjectContext.persistentStoreCoordinator = self.psc
        return managedObjectContext
    }()

    
    //Lazy loads store coordinator.
    //store coordinator mediates between the NSManagedObjectModel and the persistent store(s), so you’ll need to create a managed model and at least one persistent store.
    //First, you initialize the store coordinator using CoreDataStack’s NSManagedObjectModel, which lazy-loads it into existence (covered below).
    //Second you attach a persistent store to the store coordinator.
    private lazy var psc: NSPersistentStoreCoordinator = {
        
        let coordinator = NSPersistentStoreCoordinator(
        managedObjectModel: self.managedObjectModel)
        
        let url = self.applicationDocumentsDirectory
        .URLByAppendingPathComponent(self.modelName)
        
        do {
            let options =
            [NSMigratePersistentStoresAutomaticallyOption : true]
            
            try coordinator.addPersistentStoreWithType(
            NSSQLiteStoreType, configuration: nil, URL: url,
            options: options)
        } catch  {
            print("Error adding persistent store.")
        }
        
        return coordinator
    }()

    //3
    private lazy var managedObjectModel: NSManagedObjectModel = {
                
                let modelURL = NSBundle.mainBundle().URLForResource(self.modelName, withExtension: "momd")!
                return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    //applicationDocumentsDirectory is a lazy loaded property that returns a URL to your application’s documents directory. Why do you need this? You’re going to store the SQLite database (which is simply a file) in the documents directory. This is the recommended place to store the user’s data, whether or not you’re using Core Data.
    private lazy var applicationDocumentsDirectory: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    
    //This is a convenience method to save the stack’s managed object context and handle any errors that might result.
    func saveContext () {
            if context.hasChanges {
                do {
                    try context.save()
            } catch let error as NSError {
                print("Error: \(error.localizedDescription)")
                abort()
            }
        }
    }
}// end class CoreDataStack
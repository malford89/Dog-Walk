//
//  ViewController.swift
//  Dog Walk
//
//  Created by Pietro Rea on 7/17/15.
//  Copyright © 2015 Razeware. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDataSource {
  
  var managedContext: NSManagedObjectContext!
    
  lazy var dateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.dateStyle = .ShortStyle
    formatter.timeStyle = .MediumStyle
    return formatter
  }()
  
  @IBOutlet var tableView: UITableView!
    var currentDog: Dog!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let dogEntity = NSEntityDescription.entityForName("Dog", inManagedObjectContext: managedContext)
    let dogName = "Maeby"
    let dogFetch = NSFetchRequest(entityName: "Dog")
    dogFetch.predicate = NSPredicate(format: "name == %@", dogName)
    
    do {
        let results = try managedContext.executeFetchRequest(dogFetch) as! [Dog]
        
        if results.count > 0 { //Maeby found, use Maeby
        currentDog = results.first
        
        } else { //Maeby not found, create Maeby
            currentDog = Dog(entity: dogEntity!, insertIntoManagedObjectContext: managedContext)
            currentDog.name = dogName
            try managedContext.save()
        }
    } catch let error as NSError {
        print("Error: \(error) " +
        "description \(error.localizedDescription)")
    }
    
    tableView.registerClass(UITableViewCell.self,
      forCellReuseIdentifier: "Cell")
  }//end viewDidLoad()
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return currentDog.walks!.count
  }
  
  func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
      return "List of Walks"
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
      let cell =
      tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
      
        let walk = currentDog.walks![indexPath.row] as! Walk
        cell.textLabel!.text = dateFormatter.stringFromDate(walk.date!)
      
      return cell
  }
  
  @IBAction func add(sender: AnyObject) {
    //Insert a new Walk entity into Core Data
    let walkEntity = NSEntityDescription.entityForName("Walk", inManagedObjectContext: managedContext)
    let walk = Walk(entity: walkEntity!, insertIntoManagedObjectContext: managedContext)
    
    walk.date = NSDate()
    
    //Insert the new Walk into the Dog's walks set
    let walks = currentDog.walks!.mutableCopy() as! NSMutableOrderedSet
    
    walks.addObject(walk)
    
    currentDog.walks = walks.copy() as? NSOrderedSet
    //Save the managed object context
    do {
        try managedContext.save()
    } catch let error as NSError {
        print("Could not save:\(error)")
    }
    
    //Reload table view
    tableView.reloadData()
    
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            //First, you get a reference to the walk you want to delete.
            let walkToRemove = currentDog.walks![indexPath.row] as! Walk
            //Remove the walk from Core Data by calling NSManagedObjectContext’s deleteObject method. Core Data also takes care of removing the deleted walk from the current dog’s walks relationship.
            managedContext.deleteObject(walkToRemove)
        
            //No changes are final until you save your managed object context, not even deletions!
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save: \(error)")
            }
        //Finally, you animate the table view to tell the user about the deletion.
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }//end if
    }//end func
}//end class ViewController


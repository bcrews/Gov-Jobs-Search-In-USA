//
//  MasterViewController.swift
//  Blog Reader
//
//  Created by Bill Crews on 2/2/16.
//  Copyright © 2016 BC App Designs, LLC. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate {
  
  var detailViewController: DetailViewController? = nil
  var managedObjectContext: NSManagedObjectContext? = nil
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Core Data
    let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let context: NSManagedObjectContext = appDel.managedObjectContext
    
    let url = NSURL(string: "https://api.usa.gov/jobs/search.json?query=nursing&size=100")!
    
    let session = NSURLSession.sharedSession()
    
    let task = session.dataTaskWithURL(url) { (data, response, error) -> Void in
      
      if error != nil {
        print(error)
      } else {
        
        if let data = data {
          
          //    print(NSString(data: data, encoding: NSUTF8StringEncoding))
          
          do {
            let jsonResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as! NSArray
            
            // print(jsonResult)
            
            if jsonResult.count > 0 {
              
              // Clear Core Data
              let request = NSFetchRequest(entityName: "JobItems")
              
              request.returnsObjectsAsFaults = false
              
              do { let results = try context.executeFetchRequest(request)
                
                if results.count > 0 {
                  // Loop through and delect the items in Core Data
                  for result in results {
                    context.deleteObject(result as! NSManagedObject)
                    
                    // Save the updated cleared items
                    do { try context.save() } catch {}
                  }
                }
                
              } catch {}
              
              
              for job in jsonResult {
                
                if let position_title = job["position_title"] as? String {
                  if let organization_name = job["organization_name"] as? String {
                    if let url = job["url"] as? String {
                      
                      let newJob: NSManagedObject = NSEntityDescription.insertNewObjectForEntityForName("JobItems", inManagedObjectContext: context)
                      
                      newJob.setValue(position_title, forKey: "position_title")
                      newJob.setValue(organization_name, forKey: "organization_name")
                      newJob.setValue(url, forKey: "url")
                      
                      print(position_title)
                      print(organization_name)
                      print(url)
                    }
                  }
                }
              }
            }
          } catch {
            print("Failed to Deserialize JSON")
          }
        }
      }
    }
    
    task.resume()
    
    
    
    
    
    // Do any additional setup after loading the view, typically from a nib.
    
    if let split = self.splitViewController {
      let controllers = split.viewControllers
      self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
    }
  }
  
  override func viewWillAppear(animated: Bool) {
    self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
    super.viewWillAppear(animated)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  // MARK: - Segues
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "showDetail" {
      if let indexPath = self.tableView.indexPathForSelectedRow {
        let object = self.fetchedResultsController.objectAtIndexPath(indexPath)
        let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
        controller.detailItem = object
        controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
        controller.navigationItem.leftItemsSupplementBackButton = true
      }
    }
  }
  
  // MARK: - Table View
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    //  return self.fetchedResultsController.sections?.count ?? 0
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let sectionInfo = self.fetchedResultsController.sections![section]
    return sectionInfo.numberOfObjects
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
    self.configureCell(cell, atIndexPath: indexPath)
    return cell
  }
  
  override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the specified item to be editable.
    return true
  }
  
  override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
      let context = self.fetchedResultsController.managedObjectContext
      context.deleteObject(self.fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject)
      
      do {
        try context.save()
      } catch {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        //print("Unresolved error \(error), \(error.userInfo)")
        abort()
      }
    }
  }
  
  func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
    let object = self.fetchedResultsController.objectAtIndexPath(indexPath)
    cell.textLabel!.text = object.valueForKey("position_title")!.description
  }
  
  // MARK: - Fetched results controller
  
  var fetchedResultsController: NSFetchedResultsController {
    if _fetchedResultsController != nil {
      return _fetchedResultsController!
    }
    
    let fetchRequest = NSFetchRequest()
    // Edit the entity name as appropriate.
    let entity = NSEntityDescription.entityForName("JobItems", inManagedObjectContext: self.managedObjectContext!)
    fetchRequest.entity = entity
    
    // Set the batch size to a suitable number.
    fetchRequest.fetchBatchSize = 20
    
    // Edit the sort key as appropriate.
    let sortDescriptor = NSSortDescriptor(key: "position_title", ascending: false)
    
    fetchRequest.sortDescriptors = [sortDescriptor]
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Jobs List")
    aFetchedResultsController.delegate = self
    _fetchedResultsController = aFetchedResultsController
    
    do {
      try _fetchedResultsController!.performFetch()
    } catch {
      // Replace this implementation with code to handle the error appropriately.
      // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
      //print("Unresolved error \(error), \(error.userInfo)")
      abort()
    }
    
    return _fetchedResultsController!
  }
  var _fetchedResultsController: NSFetchedResultsController? = nil
  
  func controllerWillChangeContent(controller: NSFetchedResultsController) {
    self.tableView.beginUpdates()
  }
  
  func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
    switch type {
    case .Insert:
      self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
    case .Delete:
      self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
    default:
      return
    }
  }
  
  func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
    switch type {
    case .Insert:
      tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
    case .Delete:
      tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
    case .Update:
      self.configureCell(tableView.cellForRowAtIndexPath(indexPath!)!, atIndexPath: indexPath!)
    case .Move:
      tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
      tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
    }
  }
  
  func controllerDidChangeContent(controller: NSFetchedResultsController) {
    self.tableView.endUpdates()
  }
  
  /*
  // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
  
  func controllerDidChangeContent(controller: NSFetchedResultsController) {
  // In the simplest, most efficient, case, reload the table view.
  self.tableView.reloadData()
  }
  */
  
}


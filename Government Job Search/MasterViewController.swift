//
//  MasterViewController.swift
//  Blog Reader
//
//  Created by Bill Crews on 2/2/16.
//  Copyright © 2016 BC App Designs, LLC. All rights reserved.
//

import UIKit
import CoreData

var newSearch: Bool = true


class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate {
  
  
  var detailViewController: DetailViewController? = nil
  var managedObjectContext: NSManagedObjectContext? = nil
  var postingChannelID: String! = "?PostingChannelID=SwBqw/ctY3+Cce3bXAK/bqQzyOdZjO51gfzvhN50LlU="
  
  @IBAction func unwindToMaster(segue: UIStoryboardSegue) {
    newSearch = false
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if !newSearch {
      performSearch()
    }
    
  }
  
  override func viewDidAppear(animated: Bool) {
    if newSearch {
      performSegueWithIdentifier("JobSearchSegue", sender: self)
    } else {
      performSearch()
      self.tableView.reloadData()
    }
    
    let image = UIImage(named: "USA-Gov-Jobs-Logo-Banner")
    let imageViewHeader = UIImageView(frame: CGRect(x: 0,y: 0 , width: (self.view.bounds.width), height: (image?.size.height)!/4))
    imageViewHeader.image = image
    imageViewHeader.contentMode = .ScaleToFill
    self.tableView.tableHeaderView = imageViewHeader
    
    // Do any additional setup after loading the view, typically from a nib.
    if let split = self.splitViewController {
      let controllers = split.viewControllers
      self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
    }
  }
  
  override func prefersStatusBarHidden() -> Bool {
    return true
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
    let cell = tableView.dequeueReusableCellWithIdentifier("JobCell", forIndexPath: indexPath)
    self.configureCell(cell, atIndexPath: indexPath)
    return cell
  }
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 122
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
    
    let numberFormatter = NSNumberFormatter()
    numberFormatter.numberStyle = .CurrencyStyle
    
    
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateStyle = .ShortStyle
    
    let object = self.fetchedResultsController.objectAtIndexPath(indexPath)
    
    let jobCell = cell as! JobCell
    jobCell.position_title.text = object.valueForKey("position_title")!.description
    jobCell.organization_name.text = object.valueForKey("organization_name")!.description
    jobCell.locations.text = object.valueForKey("locations")!.description
    
    if object.valueForKey("rate_interval_code")! .isEqualToString("PA") {
      numberFormatter.maximumFractionDigits = 0
    } else { numberFormatter.maximumFractionDigits = 2 }
    
    jobCell.minimum.text = numberFormatter.stringFromNumber(object.valueForKey("minimum")! as! NSNumber)
    jobCell.maximum.text = numberFormatter.stringFromNumber(object.valueForKey("maximum")! as! NSNumber)
    jobCell.start_date.text = object.valueForKey("start_date")!.description
    jobCell.end_date.text = object.valueForKey("end_date")!.description
    let rate_code = object.valueForKey("rate_interval_code")!.description
    jobCell.rate_interval_code.text = findRateCodeDescription(rate_code)
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
 //   let sortDescriptor = NSSortDescriptor(key: "position_title", ascending: false)
    let sortDescriptor = NSSortDescriptor(key: "posting_days", ascending: true)
    
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
   // case .Update:
     // self.configureCell(tableView.cellForRowAtIndexPath(indexPath!)!, atIndexPath: indexPath!)
    case .Move:
      tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
      tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
    default:
      break
    }
  }
  
  func controllerDidChangeContent(controller: NSFetchedResultsController) {
    // self.tableView.reloadData()
     self.tableView.endUpdates()
  }
  
  var indicator = UIActivityIndicatorView()
  
  func activityIndicator(var indicator: UIActivityIndicatorView) {
    indicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 40, 40))
    indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
    indicator.center = self.view.center
    self.view.addSubview(indicator)
  }
  
  
}




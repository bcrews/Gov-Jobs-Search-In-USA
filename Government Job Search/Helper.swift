//
//  Helper.swift
//  Gov Jobs Search In USA
//
//  Created by Bill Crews on 2/15/16.
//  Copyright © 2016 BC App Designs, LLC. All rights reserved.
//

import UIKit
import CoreData

public func performSearch() {
  
  // Core Data
  let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
  let context: NSManagedObjectContext = appDel.managedObjectContext
  
  let url = NSURL(string: searchString!)!
  let session = NSURLSession.sharedSession()
  let task = session.dataTaskWithURL(url) { (data, response, error) -> Void in
    
    if error != nil {
      print(error)
    } else {
      
      if let data = data {
        // print(NSString(data: data, encoding: NSUTF8StringEncoding))
        
        do {
          let jsonResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as! NSArray
          
          // print(jsonResult)
          
          if jsonResult.count > 0 {
            
            // Clear Core Data
            let request = NSFetchRequest(entityName: "JobItems")
            
            request.returnsObjectsAsFaults = false
            
            do { let results = try context.executeFetchRequest(request)
              
              if results.count > 0 {
                
                // Loop through and delete the items in Core Data
                for result in results {
                  context.deleteObject(result as! NSManagedObject)
                  
                  // Save the updated cleared items
                  do { try context.save() } catch {print("Error in context save cleared items to CoreData")}
                }
              } else {
                
              }
              
            } catch {print("Error in context.executeFetchRequest from CoreData")}
            
            for job in jsonResult {
              
              var job_locations = ""
              
              if let position_title = job["position_title"] as? String {
                if let organization_name = job["organization_name"] as? String {
                  if var url = job["url"] as? String {
                    if let minimum = job["minimum"] as? NSNumber {
                      if let maximum = job["maximum"] as? NSNumber {
                        if var start_date = job["start_date"] as? String {
                          if var end_date = job["end_date"] as? String {
                            if let rate_code = job["rate_interval_code"] as? String {
                              if let locations = job["locations"] as? NSArray {
                                for location in locations {
                                  if (location .isEqual(locations[0])) {
                                    job_locations = location as! String
                                  } else {
                                    job_locations = job_locations + ", " + (location as! String)
                                  }
                                }
                                
                                url += postingChannelID
                                
                                start_date = convertDate(start_date)
                                end_date = convertDate(end_date)
                                
                                let newJob: NSManagedObject =
                                NSEntityDescription.insertNewObjectForEntityForName("JobItems",
                                  inManagedObjectContext: context)
                                
                                newJob.setValue(position_title, forKey: "position_title")
                                newJob.setValue(organization_name, forKey: "organization_name")
                                newJob.setValue(url, forKey: "url")
                                newJob.setValue(minimum, forKey: "minimum")
                                newJob.setValue(maximum, forKey: "maximum")
                                newJob.setValue(start_date, forKey: "start_date")
                                newJob.setValue(end_date, forKey: "end_date")
                                newJob.setValue(rate_code, forKey: "rate_interval_code")
                                newJob.setValue(job_locations, forKey: "locations")
                                
                                // print(position_title)
                                // print(organization_name)
                                // print(job_locations)
                                // print(url)
                                // print(minimum)
                                // print(maximum)
                                // print(start_date)
                                // print(end_date)
                                // print(rate_code)
                                
                              } // job_locations
                            } // rate_code
                          } // end_date
                        } // start_date
                      } // maximum
                    } // minimum
                  } // url
                } // organization_name
              }  // position_title
            }
          }
        } catch {
          print("Failed to Deserialize JSON")
        }
      }
    }
  }
  
  task.resume()
}

public func convertDate(date: String) -> String {
  let dateFormatter = NSDateFormatter()
  dateFormatter.dateFormat = "yyyy-MM-dd"
  
  let newDate = dateFormatter.dateFromString(date)
  dateFormatter.dateFormat = "MM-dd-yyyy"
  let reformatedDate = dateFormatter.stringFromDate(newDate!)
  return reformatedDate
}

public func findRateCodeDescription(rateCode: String) -> String {
  var description:String = ""
  
  switch rateCode {
  case "PH":
    description =  "per Hour"
    break
  case "PA":
    description =  "per Year"
    break
  default:
    break
  }
  return description
}



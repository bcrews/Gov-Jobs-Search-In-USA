//
//  JobSearchViewController.swift
//  Gov Jobs Search In USA
//
//  Created by Bill Crews on 2/13/16.
//  Copyright © 2016 BC App Designs, LLC. All rights reserved.
//

import UIKit


let baseURL: String = "https://api.usa.gov/jobs/search.json?"
var queryString: String = "query="
var querySize: String = "&size=250"
var searchString: String? = nil
var postingChannelID: String! = "?PostingChannelID=SwBqw/ctY3+Cce3bXAK/bqQzyOdZjO51gfzvhN50LlU="



class JobSearchViewController: UIViewController, UITextFieldDelegate {
  
  @IBOutlet weak internal var keywordSearchField: UITextField!
  @IBOutlet weak internal var locationSearchField: UITextField!
  @IBOutlet weak internal var localLocationTarget: UIImageView!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  @IBAction func submitSearchString(sender: AnyObject) {
    var keywordArray: NSArray? = nil
    var locationArray: NSArray? = nil
    var locationState: String? = nil
    var locationCity: String? = nil
    
    keywordArray =  keywordSearchField.text?.componentsSeparatedByString(",")
    locationArray = locationSearchField.text?.componentsSeparatedByString(",")
    
    if keywordArray != nil {
      
      for keyword in keywordArray! {
        if keyword .isEqual(keywordArray![0]) {
          searchString = keyword as? String
        } else {
          searchString = searchString! + "+" + (keyword as! String)
        }
      }
      for location in locationArray! {
        if (locationArray != nil) {
          if locationArray!.count > 1 {
            if location .isEqual(locationArray![1]) {
              locationCity = locationArray![0] as? String
              locationState = locationArray![1] as? String
              searchString = searchString! + "+in+" + locationState!
            }
          } else {
            locationState = locationArray![0] as? String
            searchString = searchString! + "+in+" + locationState!
          }
        }
      }
      searchString = searchString!.stringByReplacingOccurrencesOfString(" ", withString: "")
      searchString = baseURL + queryString + searchString! + querySize
      print(searchString!)
      
      newSearch = false
      
    performSegueWithIdentifier("unwindToMaster", sender: self)
      
    }
  }
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
  
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    
    let nextTag = textField.tag + 1
  
    if nextTag == 2 {
      textField.resignFirstResponder()
    }
    // Find next responder
    let nextResponder = textField.superview?.viewWithTag(nextTag) as UIResponder!
    
    if (nextResponder != nil) {
      // Found next responder, set it
      nextResponder?.becomeFirstResponder()
    } else {
      // Not found, so remove keyboard
      textField.resignFirstResponder()
    }
    return false // We do not want UITextField to insert line-breaks.
  }
  
}

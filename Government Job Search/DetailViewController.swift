//
//  DetailViewController.swift
//  Blog Reader
//
//  Created by Bill Crews on 2/2/16.
//  Copyright © 2016 BC App Designs, LLC. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
  
  var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
  
  @IBOutlet weak var webview: UIWebView!
  
  
  var detailItem: AnyObject? {
    didSet {
      // Update the view.
      self.configureView()
    }
  }
  
  func configureView() {
    // Update the user interface for the detail item.
    if let detail = self.detailItem {
      if let jobWebView = self.webview {
        startActivityIndicator(jobWebView)
        let url = NSURL(string: detail.valueForKey("url")!.description)
        let urlRequest = NSURLRequest(URL: url!)
        jobWebView.loadRequest(urlRequest)
        stopActivityIndicator()
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
 
    self.configureView()
   
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func startActivityIndicator(view: UIWebView) {
    activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0,0,50,50))
    activityIndicator.center = view.center
    activityIndicator.hidesWhenStopped = true
    activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
    view.addSubview(activityIndicator)
    UIApplication.sharedApplication().beginIgnoringInteractionEvents()
  }
  
  func stopActivityIndicator() {
    activityIndicator.stopAnimating()
    UIApplication.sharedApplication().endIgnoringInteractionEvents()
  }
  
  
}


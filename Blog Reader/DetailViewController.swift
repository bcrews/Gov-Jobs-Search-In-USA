//
//  DetailViewController.swift
//  Blog Reader
//
//  Created by Bill Crews on 2/2/16.
//  Copyright © 2016 BC App Designs, LLC. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

  
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
          
          let url = NSURL(string: detail.valueForKey("url")!.description)
          let urlRequest = NSURLRequest(URL: url!)
          jobWebView.loadRequest(urlRequest)
          
        }
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    self.configureView()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}


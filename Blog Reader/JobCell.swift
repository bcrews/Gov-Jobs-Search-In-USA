//
//  JobCell.swift
//  Gov Jobs Search In USA
//
//  Created by Bill Crews on 2/4/16.
//  Copyright © 2016 BC App Designs, LLC. All rights reserved.
//

import UIKit

class JobCell: UITableViewCell {
  
  @IBOutlet weak var position_title: UILabel!
  @IBOutlet weak var organization_name: UILabel!
  @IBOutlet weak var locations: UILabel!
  @IBOutlet weak var minimum: UILabel!
  @IBOutlet weak var maximum: UILabel!
  @IBOutlet weak var start_date: UILabel!
  @IBOutlet weak var end_date: UILabel!
  @IBOutlet weak var rate_interval_code: UILabel!
  
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}

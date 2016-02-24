//
//  JobItems+CoreDataProperties.swift
//  Gov Jobs Search In USA
//
//  Created by Bill Crews on 2/23/16.
//  Copyright © 2016 BC App Designs, LLC. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension JobItems {

    @NSManaged var url: String?
    @NSManaged var start_date: String?
    @NSManaged var rate_interval_code: String?
    @NSManaged var posting_days: NSNumber?
    @NSManaged var position_title: String?
    @NSManaged var organization_name: String?
    @NSManaged var minimum: NSNumber?
    @NSManaged var maximum: NSNumber?
    @NSManaged var locations: String?
    @NSManaged var id: String?
    @NSManaged var end_date: String?

}

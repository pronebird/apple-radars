//
//  Event+CoreDataProperties.swift
//  NSFetchedResultsControllerBugIOS9GM
//
//  Created by pronebird on 9/14/15.
//  Copyright © 2015 pronebird. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Event {

    @NSManaged var sectionKey: String?
    @NSManaged var title: String?
    @NSManaged var marked: NSNumber?

}

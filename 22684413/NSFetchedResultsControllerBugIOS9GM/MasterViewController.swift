//
//  MasterViewController.swift
//  NSFetchedResultsControllerBugIOS9GM
//
//  Created by pronebird on 9/10/15.
//  Copyright © 2015 pronebird. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var managedObjectContext: NSManagedObjectContext? = nil
    var counter = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.editButtonItem()

        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
        self.navigationItem.rightBarButtonItem = addButton
    }
    
    func insertNewObject(sender: AnyObject) {
        let context = self.fetchedResultsController.managedObjectContext
        let entity = self.fetchedResultsController.fetchRequest.entity!
        let event = NSEntityDescription.insertNewObjectForEntityForName(entity.name!, inManagedObjectContext: context) as! Event
        
        counter++
             
        // If appropriate, configure the new managed object.
        // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
        event.sectionKey = "Active"
        event.title = "Item \(counter)"
        
        // Save the context.
        do {
            try context.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            //print("Unresolved error \(error), \(error.userInfo)")
            abort()
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        let event = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Event
        
        cell.textLabel!.text = event.title
        
        if event.marked!.boolValue {
            cell.accessoryType = .Checkmark
        }
        else {
            cell.accessoryType = .None
        }
        
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {}
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let context = self.fetchedResultsController.managedObjectContext
        let event = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Event
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        event.marked = NSNumber(bool: !event.marked!.boolValue)
        
        _ = try? context.save()
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let event = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Event
        
        let trash = UITableViewRowAction(style: .Normal, title: "Trash") { [weak self] (action, indexPath) -> Void in
            guard let _self = self else { return }
            let context = _self.fetchedResultsController.managedObjectContext
            let event = _self.fetchedResultsController.objectAtIndexPath(indexPath) as! Event
            
            event.sectionKey = "Inactive"
            
            _ = try? context.save()
        }
        
        let delete = UITableViewRowAction(style: .Default, title: "Delete") { [weak self] (action, indexPath) -> Void in
            guard let _self = self else { return }
            let context = _self.fetchedResultsController.managedObjectContext
            let event = _self.fetchedResultsController.objectAtIndexPath(indexPath) as! Event
            
            context.deleteObject(event)
            
            _ = try? context.save()
        }
        
        let restore = UITableViewRowAction(style: .Normal, title: "Restore") { [weak self] (action, indexPath) -> Void in
            guard let _self = self else { return }
            let context = _self.fetchedResultsController.managedObjectContext
            let event = _self.fetchedResultsController.objectAtIndexPath(indexPath) as! Event
            
            event.sectionKey = "Active"
            
            _ = try? context.save()
        }
        
        if event.sectionKey == "Inactive" {
            return [delete, restore]
        }
        else {
            return [trash]
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.fetchedResultsController.sections?[section].indexTitle
    }

    // MARK: - Fetched results controller

    var fetchedResultsController: NSFetchedResultsController {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest = NSFetchRequest()
        // Edit the entity name as appropriate.
        let entity = NSEntityDescription.entityForName("Event", inManagedObjectContext: self.managedObjectContext!)
        fetchRequest.entity = entity
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptorForTitle = NSSortDescriptor(key: "title", ascending: false)
        let sortDescriptorForSection = NSSortDescriptor(key: "sectionKey", ascending: true, selector: "localizedCompare:")
        
        fetchRequest.sortDescriptors = [sortDescriptorForSection, sortDescriptorForTitle]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: "sectionKey", cacheName: nil)
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
                print("didChangeSection: Insert \(sectionIndex)")
            case .Delete:
                self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
                print("didChangeSection: Delete \(sectionIndex)")
            default:
                return
        }
    }

    @objc func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
            case .Insert:
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
                print("didChangeObject: Insert \(newIndexPath!)")
            case .Delete:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
                print("didChangeObject: Delete \(indexPath!)")
            case .Update:
                tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
                print("didChangeObject: Update \(indexPath!)")
            break
            case .Move:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
                print("didChangeObject: Move \(indexPath!) -> \(newIndexPath!)")
        }
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, sectionIndexTitleForSectionName sectionName: String) -> String? {
        return sectionName
    }

}


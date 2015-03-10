//
//  RemindersListController.swift
//  yuLocate
//
//  Created by Yenkay on 14/02/15.
//  Copyright (c) 2015 yenkay. All rights reserved.
//

import UIKit

class RemindersListController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var remindersTable: UITableView!
    
    @IBOutlet var counter: UIBarButtonItem!
    
    var yuDb = YuLocate.getInstance()
    
    var row = [SQLRow]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        remindersTable.delegate = self
        remindersTable.dataSource = self
        refreshTable()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return row.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("reminderCell", forIndexPath: indexPath) as ReminderCell
        var eachRow = row[indexPath.row]
        var entry = String()
        
        if let description = eachRow["description"] {
            cell.messageLabel.text = description.asString()
        }
        if let lat = eachRow["latitude"] {
            entry = "" + lat.asString()
            cell.latitude = lat.asDouble()
        }
        if let lng = eachRow["longitude"] {
            entry += ", " + lng.asString()
            cell.longitude = lng.asDouble()
        }
        cell.latsLabel.text = entry
        
        if let date = eachRow["remindDate"] {
            cell.dateLabel.text = date.asString()
        }
        
        if let id = eachRow["remindId"] {
            cell.id = id.asInt()
        }
        
        return cell
    }
    
    @IBAction func reloadAction(sender: UIBarButtonItem) {
        refreshTable()
    }
    
    func refreshTable() {
        row = yuDb.getReminders()
        counter.title = "\(row.count)"
        remindersTable.reloadData()
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if(editingStyle == UITableViewCellEditingStyle.Delete) {
            NSLog("Delete")
            
        }
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        var moreRowAction = UITableViewRowAction(
            style: UITableViewRowActionStyle.Default,
            title: "Map",
            handler: {
                action,
                indexpath in
                
                //self.performSegueWithIdentifier("detailLocation", sender: self)
                
        })
        moreRowAction.backgroundColor = UIColor(red: 0.298, green: 0.851, blue: 0.3922, alpha: 1.0)
        
        var deleteRowAction = UITableViewRowAction(
            style: UITableViewRowActionStyle.Default,
            title: "Remove",
            handler: {
                action,
                indexpath in
                
                var cell = tableView.cellForRowAtIndexPath(indexPath) as ReminderCell
                self.yuDb.cancelReminder(cell.id)
                self.remindersTable.beginUpdates()
                self.remindersTable.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Left)
                self.remindersTable.endUpdates()
                
        })
        deleteRowAction.backgroundColor = UIColor(red: 0.851, green: 0.298, blue: 0.3922, alpha: 1.0)
        
        return [deleteRowAction, moreRowAction]
    }
}
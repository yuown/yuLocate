//
//  HistoryController.swift
//  yuLocate
//
//  Created by Yenkay on 10/01/15.
//  Copyright (c) 2015 yenkay. All rights reserved.
//

import UIKit

class HistoryController:UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var clientHelper = YuLocateClientHelper.getInstance()
    
    @IBOutlet var totalCtr: UILabel!
    
    @IBOutlet var historyTable: UITableView!
    
    let yuDb = YuLocate.getInstance()
    
    var row = [SQLRow]()
    
    var indexPath : NSIndexPath!
    
    var datePicker:UIDatePicker!

    @IBOutlet var txtDate: UITextField!
    
    @IBOutlet var fetchHistoryBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        historyTable.dataSource = self
        historyTable.delegate = self
        historyTable.estimatedRowHeight = 110
        //historyTable.rowHeight = UITableViewAutomaticDimension
        
        datePicker = UIDatePicker()
        datePicker.datePickerMode = UIDatePickerMode.Date
        datePicker.addTarget(self, action: "selectDate:", forControlEvents: UIControlEvents.ValueChanged)
        txtDate.inputView = datePicker
        selectDate(datePicker)
        refreshTable(datePicker.date)
    }
    
    @IBAction func fetchHistory(sender: UIButton) {
        txtDate.resignFirstResponder()
        refreshTable(datePicker.date)
    }
    
    @IBAction func tappedOut(sender: UITapGestureRecognizer) {
        txtDate.resignFirstResponder()
    }
    
    func refreshTable(date: NSDate) {
        fetchHistoryBtn.enabled = false
        row = yuDb.getHistoryByDate(date)
        historyTable.reloadData()
        fetchHistoryBtn.enabled = true
        totalCtr.text = "Locations Visited: \(row.count)"
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return row.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) ->   UITableViewCell {

        let cell1 : LocationCell = tableView.dequeueReusableCellWithIdentifier("locationCell", forIndexPath: indexPath) as LocationCell

        var address = Address()
        var eachRow = row[indexPath.row]
        var entry = String()

        if let d = eachRow["date"] {
            cell1.dateLabel.text = d.asString()
            address.dateTime = d.asString()
        }
        if let lat = eachRow["latitude"] {
            entry += "\(lat.asString()), "
            address.latitude = lat.asDouble()
        }
        if let lon = eachRow["longitude"] {
            entry += "\(lon.asString())"
            address.longitude = lon.asDouble()
        }
        cell1.latLngLabel.text = entry
        
        entry = ""
        if let subLoc = eachRow["subLocality"] {
            entry = "\(subLoc.asString())"
            if(entry != "") {
                entry += ","
            }
            address.subLocality = subLoc.asString()
        }
        if let loc = eachRow["locality"] {
            entry += "\(loc.asString()), "
            address.locality = loc.asString()
        }
        if let aArea = eachRow["administrativeArea"] {
            entry += "\(aArea.asString()), "
            address.administrativeArea = aArea.asString()
        }
        if let pc = eachRow["postalCode"] {
            entry += "\(pc.asString()), "
            address.postalCode = pc.asString()
        }
        if let country = eachRow["country"] {
            entry += "\(country.asString())"
            address.country = country.asString()
        }
        if let speed = eachRow["speed"] {
            address.speed = speed.asDouble()
        }
        cell1.detailsLabel.text = entry
        cell1.address = address

        if(entry != "") {
            cell1.latLngLabel.hidden = true
            cell1.detailsLabel.hidden = false
        } else {
            cell1.latLngLabel.hidden = false
            cell1.detailsLabel.hidden = true
        }
        
        return cell1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 110
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        yuDb.dblog("commitEditingStyle")
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        var moreRowAction = UITableViewRowAction(
                    style: UITableViewRowActionStyle.Default,
                    title: "More",
                    handler: {
                                action,
                                indexpath in
                                self.indexPath = indexPath
                                self.performSegueWithIdentifier("detailLocation", sender: self)
                            })
        moreRowAction.backgroundColor = UIColor(red: 0.298, green: 0.851, blue: 0.3922, alpha: 1.0);
        return [moreRowAction]
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var cell = self.historyTable.cellForRowAtIndexPath(self.indexPath) as LocationCell
        (segue.destinationViewController as LocationDetailsController).address = cell.address
    }
    
    func selectDate(sender: UIDatePicker) {
        txtDate.text = yuDb.dateType2String(datePicker.date)
        //txtDate.resignFirstResponder()
    }
}
//
//  LogController.swift
//  yuLocate
//
//  Created by Yenkay on 06/02/15.
//  Copyright (c) 2015 yenkay. All rights reserved.
//

import UIKit

class LogController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var todayLogs = [LogEntry]()
    
    var yuDb = YuLocate.getInstance()
    
    @IBOutlet var logTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logTable.dataSource = self
        logTable.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        todayLogs = yuDb.getTodayLogs()
        logTable.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todayLogs.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : LogCell = tableView.dequeueReusableCellWithIdentifier("logCell", forIndexPath: indexPath) as LogCell
        
        cell.logDate.text = todayLogs[indexPath.row].logDate
        cell.logMessage.text = todayLogs[indexPath.row].logMessage
        
        return cell
    }
    @IBAction func clearLogs(sender: UIButton) {
        yuDb.clearAllLogs()
        logTable.reloadData()
    }
}

//
//  LogCell.swift
//  yuLocate
//
//  Created by Yenkay on 06/02/15.
//  Copyright (c) 2015 yenkay. All rights reserved.
//

import UIKit


class LogCell: UITableViewCell {
    
    @IBOutlet var logDate: UILabel!
    
    @IBOutlet var logMessage: UILabel!

}

class LogEntry: NSObject {
    
    var logDate: String!
    
    var logMessage: String!
    
}
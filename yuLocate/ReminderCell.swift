//
//  ReminderCell.swift
//  yuLocate
//
//  Created by Yenkay on 15/02/15.
//  Copyright (c) 2015 yenkay. All rights reserved.
//

import UIKit

class ReminderCell: UITableViewCell {
    
    @IBOutlet var messageLabel: UILabel!
    
    @IBOutlet var latsLabel: UILabel!
    
    @IBOutlet var dateLabel: UILabel!
    
    var latitude: Double!
    
    var longitude: Double!
    
    var id: Int!
}

//
//  LocationStatisticsController.swift
//  yuLocate
//
//  Created by Yenkay on 26/01/15.
//  Copyright (c) 2015 yenkay. All rights reserved.
//

import UIKit

class LocationStatisticsController: UIViewController {
    
    @IBOutlet var withAddress: UILabel!
    
    @IBOutlet var withoutAddress: UILabel!
    
    @IBOutlet var onlyOnApp: UILabel!
    
    @IBOutlet var synched2Server: UILabel!
    
    @IBOutlet var reloadBtn: UIButton!
    
    var yuDb = YuLocate.getInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reloadStats(reloadBtn)
    }
    
    @IBAction func reloadStats(sender: UIButton) {
        var result = yuDb.loadStats()
        withAddress.text = "With Address: \(result.0)"
        withoutAddress.text = "Without Address: \(result.1)"
        onlyOnApp.text = "Not-Sync to Server: \(result.2)"
        synched2Server.text = "Synched to Server: \(result.3)"
    }
}

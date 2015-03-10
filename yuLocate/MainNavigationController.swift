//
//  MainNavigationController.swift
//  yuLocate
//
//  Created by Yenkay on 14/02/15.
//  Copyright (c) 2015 yenkay. All rights reserved.
//

import UIKit

class MainNavigationController: UINavigationController {
    
    var yuDb = YuLocate.getInstance()
    
    var pinEnabled = YuLocate.getInstance().getPinConfig()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(pinEnabled == 0) {
            self.performSegueWithIdentifier("go2home1", sender: self)
        } else {
            self.performSegueWithIdentifier("go2login", sender: self)
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        return true
    }
    
}

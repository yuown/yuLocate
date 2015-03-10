//
//  HomeNavigator.swift
//  yuLocate
//
//  Created by Yenkay on 06/01/15.
//  Copyright (c) 2015 yenkay. All rights reserved.
//

import UIKit


class HomeNavigator:UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let delegate = UIApplication.sharedApplication().delegate as AppDelegate
        delegate.mainTabController = self
        // yuDb.dblog("Home View Loaded")
    }
    
}
//
//  YuLocateClientHelper.swift
//  yuLocate
//
//  Created by Yenkay on 23/01/15.
//  Copyright (c) 2015 yenkay. All rights reserved.
//

import UIKit

class YuLocateClientHelper: NSObject {
    
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
    
    var mapLats2Addr = 1
    
    var syncWithServer = 1
    
    var background = 1
    
    var yuDb = YuLocate.getInstance()
    
    required override init() {
        super.init()
        getConfig()
    }
    
    struct Static {
        static var instance:YuLocateClientHelper? = nil
        static var token:dispatch_once_t = 0
    }
    
    class func getInstance() -> YuLocateClientHelper! {
        dispatch_once(&Static.token) {
            Static.instance = self()
        }
        return Static.instance!
    }
    
    func getConfig() {
        mapLats2Addr = yuDb.getConfig("generateAddress")
        syncWithServer = yuDb.getConfig("sync2server")
        background = yuDb.getConfig("background")
    }
    
    var datePicker = UIDatePicker()
    
    class func alert(message:String, controller: UIViewController) {
        var alert:UIAlertController = UIAlertController(title: "yuLocate", message: message, preferredStyle: .Alert)
        var ok=UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(ok)
        controller.presentViewController(alert, animated: true, completion: nil)
    }
    
    func datePopup(controller: UIViewController) {
        self.datePicker.datePickerMode = UIDatePickerMode.Date
        self.datePicker.addTarget(self, action: "datePickerSelected", forControlEvents: UIControlEvents.ValueChanged)

        
    }
    
    func datePickerSelected() {
        yuDb.dblog("datePickerSelected")
    }
    
    func isValidEmail(email: String) -> Bool {
        var emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest?.evaluateWithObject(email)
        return result!
    }
}

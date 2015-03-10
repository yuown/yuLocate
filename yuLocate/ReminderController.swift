//
//  ReminderController.swift
//  yuLocate
//
//  Created by Yenkay on 01/02/15.
//  Copyright (c) 2015 yenkay. All rights reserved.
//

import UIKit

class ReminderController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet var latitude: UILabel!
    
    @IBOutlet var longitude: UILabel!
    
    @IBOutlet var date: UITextField!
    
    @IBOutlet var remindMessage: UITextView!
    
    var yuDb = YuLocate.getInstance()
    
    var keys: [Int]!
    
    var values: [String]!
    
    var parentView: UIView!
    
    var currentLocationController: CurrentLocationController!
    
    @IBOutlet var tapper: UITapGestureRecognizer!
    
    @IBOutlet var scrollView: UIScrollView!
    
    var dateControl: UIDatePicker!
    
    var lat: Double!
    
    var long: Double!
    
    var selectedDate: NSDate!
    
    @IBOutlet var closeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var allReminderValues = yuDb.getRemindDurations()
        keys = allReminderValues.0
        values = allReminderValues.1
        scrollView.addGestureRecognizer(tapper)
        
        dateControl = UIDatePicker()
        dateControl.datePickerMode = UIDatePickerMode.DateAndTime
        dateControl.addTarget(self, action: "selectDate:", forControlEvents: UIControlEvents.ValueChanged)
        date.inputView = dateControl
        
        selectDate(dateControl)
    }
    
    @IBAction func closeSubView(sender: UIButton) {
        let delegate = UIApplication.sharedApplication().delegate as AppDelegate
        currentLocationController = delegate.currentLocationController
        currentLocationController.hideSubView(false)
        
        date.resignFirstResponder()
        remindMessage.resignFirstResponder()
    }
    
    @IBAction func createReminder(sender: UIButton) {
        yuDb.createReminder(lat, longitude: long, message: remindMessage.text, remindDate: date.text, remindBefore: 5)
        var notification = UILocalNotification()
        notification.fireDate = dateControl.date
        notification.timeZone = NSTimeZone.systemTimeZone()
        notification.alertBody = remindMessage.text
        notification.alertAction = "yuLocate Reminder"
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        
        let delegate = UIApplication.sharedApplication().delegate as AppDelegate
        currentLocationController = delegate.currentLocationController
        currentLocationController.hideSubView(true)
        
        date.resignFirstResponder()
        remindMessage.resignFirstResponder()
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return keys.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return values[row]
    }
    
    @IBAction func tapOutside(sender: UITapGestureRecognizer) {
        date.resignFirstResponder()
        remindMessage.resignFirstResponder()
    }
    
    func setData(latitude: Double, longitude: Double) {
        lat = latitude
        long = longitude
        self.latitude.text = "Latitude: \(latitude)"
        self.longitude.text = "Latitude: \(longitude)"
        dateControl.date = NSDate()
        selectDate(dateControl)
    }
    
    func selectDate(dateControl: UIDatePicker) {
        selectedDate = dateControl.date
        date.text = yuDb.date2StringMins(selectedDate)
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        date.resignFirstResponder()
        remindMessage.resignFirstResponder()
    }
}
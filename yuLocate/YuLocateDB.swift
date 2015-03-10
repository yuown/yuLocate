//
//  YuLocateDB.swift
//  yuLocate
//
//  Created by Yenkay on 12/01/15.
//  Copyright (c) 2015 yenkay. All rights reserved.
//

import GoogleMaps

class YuLocate: NSObject {

    var db = SQLiteDB.sharedInstance()
    
    var getPinConfigQuery = "SELECT value from config where name = 'pin'"
    
    var updatePinConfigQuery = "UPDATE CONFIG SET VALUE = ? WHERE NAME = 'pin'"
    
    var historyByDateQuery = "SELECT * FROM location where date like ? order by localId desc"
    
    var getUserByID = "SELECT * FROM user where email = ?"
    
    var getUserByPIN = "SELECT * FROM user where pin = ?"
    
    var getUserCountQuery = "SELECT count(1) as uCount FROM user"
    
    var allUsers = "SELECT * FROM user"
    
    var createUser = "INSERT INTO user (email, pin) values (?, ?)"
    
    var updatePIN = "UPDATE user set pin = ? where pin = ?"
    
    var getConfigQuery = "SELECT value from config where name = ?"
    
    var updateConfigQuery = "UPDATE config set value = ? where name = ?"
    
    var statsQuery = "SELECT * FROM (" +
        "(SELECT count(localId) as wA from location where hasAddr = 1), " +
        "(SELECT count(localId) as woA from location where hasAddr = 0), " +
        "(SELECT count(localId) as oA from location where polledServer = 0), " +
        "(SELECT count(localId) as s2s from location where polledServer = 1)" +
    ")"
    
    var remindDurationsQuery = "SELECT name, value from remind_durations order by id"
    
    var dbLogEntry = "INSERT INTO log (date, message) values (?, ?)"
    
    var getTodayLogsQuery = "SELECT date, message from log where date like ? order by logId"
    
    var clearAllLogsQuery = "DELETE FROM log"
    
    var createReminderQuery = "INSERT INTO reminder (description, latitude, longitude, remindDate, deleted) values (?, ?, ?, ?, 0)"
    
    var getRemindersQuery = "SELECT * FROM reminder where deleted = 0 order by remindId"
    
    var cancelReminderQuery = "UPDATE reminder set deleted = 1 where remindId = ?"
    
    var pin = [SQLRow]()
    
    var user = [SQLRow]()
    
    var pinEnabled = 1
    
    let dateFormat = "yyyy-MM-dd HH:mm:ss"
    
    let dateFormatter = NSDateFormatter()
    
    let dateOnlyFormat = "yyyy-MM-dd"
    
    let dateOnlyFormatter = NSDateFormatter()
    
    let dateFormatMins = "yyyy-MM-dd HH:mm"
    
    let dateFormatterMins = NSDateFormatter()
    
    required override init() {
        super.init()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        
        dateOnlyFormatter.dateFormat = dateOnlyFormat
        dateOnlyFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        
        dateFormatterMins.dateFormat = dateFormatMins
        dateFormatterMins.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        
        pin = db.query(getPinConfigQuery)
    }
    
    struct Static {
        static var instance:YuLocate? = nil
        static var token:dispatch_once_t = 0
    }
    
    class func getInstance() -> YuLocate! {
        dispatch_once(&Static.token) {
            Static.instance = self()
        }
        return Static.instance!
    }
    
    func getPinConfig() -> Int {
        var pinRow = pin[0]
        if let enablePin = pinRow["value"] {
            pinEnabled = enablePin.asInt()
        }
        return pinEnabled
    }
    
    func updatePinConfig(enabled: Int) {
        db.execute(updatePinConfigQuery, parameters: [enabled])
    }
    
    func saveCurrentLocation2DB(address:Address) {
        var now = NSDate()
        db.execute("INSERT INTO location (date, latitude, longitude, subLocality, locality, administrativeArea, postalCode, country, speed, hasAddr, polledServer) values (?, ?, ?, ?, ?, ?, ?, ?, ?, 1, 0)", parameters: [date2String(now), address.latitude, address.longitude, address.subLocality, address.locality, address.administrativeArea, address.postalCode, address.country, address.speed])
    }
    
    func saveCurrentLocation2DB(location:CLLocation) {
        var now = NSDate()
        db.execute("INSERT INTO location (date, latitude, longitude, speed, hasAddr, polledServer) values (?, ?, ?, ?, 0, 0)", parameters: [date2String(now), location.coordinate.latitude, location.coordinate.longitude, location.speed.description])
    }
    
    func getHistoryByDate(date: NSDate) -> [SQLRow] {
        return db.query(historyByDateQuery, parameters: [dateOnlyFormatter.stringFromDate(date) + "%"])
    }
    
    func date2String(date:NSDate) -> String {
        return dateFormatter.stringFromDate(date)
    }
    
    func date2StringMins(date:NSDate) -> String {
        return dateFormatterMins.stringFromDate(date)
    }
    
    func getAllUsersFunc() -> (String, String) {
        var uCount = db.query(allUsers)
        var emailVal = "", pinVal = ""
        if(uCount.count > 0) {
            var uCRow = uCount[0]
            
            if let eCol = uCRow["email"] {
                emailVal = eCol.asString()
            }
            if let pCol = uCRow["pin"] {
                pinVal = pCol.asString()
            }
        }
        dblog("User: \(emailVal) and \(pinVal)")
        return (emailVal, pinVal)
    }
    
    func getUserCount() -> Int {
        var uCount = db.query(getUserCountQuery)
        var uCRow = uCount[0]
        var uC = 0
        if let uCol = uCRow["uCount"] {
            uC = uCol.asInt()
        }
        //getAllUsersFunc()
        dblog("User Count: \(uC)")
        return uC
    }
    
    func createUser(email:String, pin:String) {
        db.execute(createUser, parameters: [email, pin])
    }
    
    func isUserPINValid(pinReq: String) -> Bool {
        var emailNPin = getAllUsersFunc()
        return emailNPin.1 == pinReq
    }
    
    func dateType2String(date: NSDate) -> String {
        return dateOnlyFormatter.stringFromDate(date)
    }
    
    func updatePIN(oldPin: String, newPin: String) {
        db.execute(updatePIN, parameters: [newPin, oldPin])
    }
    
    func getConfig(configName: String) -> Int {
        var configRow = db.query(getConfigQuery, parameters: [configName])
        var row = configRow[0]
        var value = 0
        if let confVal = row["value"] {
            value = confVal.asInt()
        }
        return value
    }
    
    func updateConfig(configName: String, configValue: Int) {
        db.execute(updateConfigQuery, parameters: [configValue, configName])
    }
    
    func loadStats() -> (Int, Int, Int, Int) {
        var statsRow = db.query(statsQuery)
        var row = statsRow[0]
        var wA = 0, woA = 0, oA = 0, s2s = 0
        if let wAVal = row["wA"] {
            wA = wAVal.asInt()
        }
        if let woAVal = row["woA"] {
            woA = woAVal.asInt()
        }
        if let oAVal = row["oA"] {
            oA = oAVal.asInt()
        }
        if let s2sVal = row["s2s"] {
            s2s = s2sVal.asInt()
        }
        return (wA, woA, oA, s2s)
    }
    
    func getRemindDurations() -> ([Int], [String]) {
        var rawRow = db.query(remindDurationsQuery)
        //var allRemindDurations = Dictionary<Int, String>(minimumCapacity: 17)
        var keys = [Int]()
        var values = [String]()
        for(var i = 0; i < rawRow.count; i++) {
            var eachRow = rawRow[i]
            var value = 0, name = ""
            if let val = eachRow["value"] {
                keys.append(val.asInt())
            }
            if let nam = eachRow["name"] {
                values.append(nam.asString())
            }
            //allRemindDurations.updateValue(name, forKey: value)
        }
        return (keys, values)
    }
    
    func createReminder(latitude: Double, longitude: Double, message: String, remindDate: String, remindBefore: Int) {
        db.execute(createReminderQuery, parameters: [message, latitude, longitude, remindDate])
    }
    
    func dblog(message: String) {
        NSLog(message)
        db.execute(dbLogEntry, parameters: [date2String(NSDate()), message])
    }
    
    func getTodayLogs() -> [LogEntry]{
        var allLogRows = db.query(getTodayLogsQuery, parameters: [dateOnlyFormatter.stringFromDate(NSDate()) + "%"])
        var logEntries = [LogEntry]()
        for(var i = 0; i < allLogRows.count; i++) {
            var logEntry = LogEntry()
            var eachRow = allLogRows[i]
            if let dateVal = eachRow["date"] {
                logEntry.logDate = dateVal.asString()
            }
            if let messageVal = eachRow["message"] {
                logEntry.logMessage = messageVal.asString()
            }
            logEntries.append(logEntry)
        }
        return logEntries
    }
    
    func clearAllLogs() {
        db.execute(clearAllLogsQuery)
    }
    
    func getReminders() -> [SQLRow] {
        return db.query(getRemindersQuery)
    }
    
    func cancelReminder(id: Int) {
        db.execute(cancelReminderQuery, parameters: [id])
    }
}

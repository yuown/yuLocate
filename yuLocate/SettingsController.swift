//
//  SettingsController.swift
//  yuLocate
//
//  Created by Yenkay on 10/01/15.
//  Copyright (c) 2015 yenkay. All rights reserved.
//

import UIKit
import CoreLocation

class SettingsController: UITableViewController {
    
    @IBOutlet var enablePin: UISwitch!

    @IBOutlet var mapLats2Addr: UISwitch!
    
    @IBOutlet var syncWithServer: UISwitch!

    @IBOutlet var backgroundUpdatesSwitch: UISwitch!
    
    var yuDb = YuLocate.getInstance()
    
    var clientHelper = YuLocateClientHelper.getInstance()
    
    var locationManager:CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let delegate = UIApplication.sharedApplication().delegate as AppDelegate
        locationManager = delegate.locationManager
        
        enablePin.setOn(yuDb.getPinConfig() == 1 ? true : false, animated: true)
        mapLats2Addr.setOn(clientHelper.mapLats2Addr == 1 ? true : false, animated: true)
        syncWithServer.setOn(clientHelper.syncWithServer == 1 ? true : false, animated: true)
        backgroundUpdatesSwitch.setOn(clientHelper.background == 1 ? true : false, animated: true)
    }
    
    @IBAction func changePinConfig(sender: UISwitch) {
        yuDb.updatePinConfig(sender.on == true ? 1 : 0)
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if(identifier == "changePIN" && enablePin.on == false) {
            YuLocateClientHelper.alert("PIN can be changed only when PIN is enabled", controller: self)
            return false
        }
        
        return true
    }
    
    @IBAction func mapLats2Address(sender: UISwitch) {
        yuDb.updateConfig("generateAddress", configValue: sender.on == true ? 1 : 0)
        clientHelper.mapLats2Addr = sender.on == true ? 1 : 0
    }
    
    @IBAction func syncWithServer(sender: UISwitch) {
        yuDb.updateConfig("sync2server", configValue: sender.on == true ? 1 : 0)
        clientHelper.syncWithServer = sender.on == true ? 1 : 0
    }
    
    @IBAction func configureBackgroundUpdates(sender: UISwitch) {
        yuDb.updateConfig("background", configValue: sender.on == true ? 1 : 0)
        clientHelper.background = 1//sender.on == true ? 1 : 0
        
        if(sender.on == true) {
            locationManager.startMonitoringSignificantLocationChanges()
            locationManager.startUpdatingLocation()
        } else {
            locationManager.stopMonitoringSignificantLocationChanges()
            locationManager.stopUpdatingLocation()
        }
    }
}

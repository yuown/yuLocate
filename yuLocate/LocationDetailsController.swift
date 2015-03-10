//
//  LocationDetails.swift
//  yuLocate
//
//  Created by Yenkay on 16/01/15.
//  Copyright (c) 2015 yenkay. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class LocationDetailsController: UIViewController {
    
    @IBOutlet var latLabel: UILabel!
    
    @IBOutlet var lngLabel: UILabel!
    
    @IBOutlet var addressLabel: UILabel!
    
    @IBOutlet var dateTimeLabel: UILabel!
    
    @IBOutlet var speedLabel: UILabel!
    
    var address : Address!
    
    var currentLocationController: CurrentLocationController!
    
    var mainTabController: HomeNavigator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showLocationInfo()
        
        let delegate = UIApplication.sharedApplication().delegate as AppDelegate
        currentLocationController = delegate.currentLocationController
        mainTabController = delegate.mainTabController
    }
    
    func showLocationInfo() {
        latLabel.text = address?.latitude.description
        lngLabel.text = address?.longitude.description
        dateTimeLabel.text = address?.dateTime
        speedLabel.text = address?.speed.description
        addressLabel.text = "\(address.subLocality)\n\(address.locality)\n\(address.administrativeArea)\n\(address.postalCode)\n\(address.country)"
    }
    
    @IBAction func locateMeOnMap(sender: UIButton) {
        currentLocationController.showCustomLocationOnMap(address)
        mainTabController.selectedViewController = currentLocationController
    }
}
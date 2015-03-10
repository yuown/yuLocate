//
//  Address.swift
//  yuLocate
//
//  Created by Yenkay on 16/01/15.
//  Copyright (c) 2015 yenkay. All rights reserved.
//

import Foundation

class Address: NSObject {
    
    var dateTime : String = ""
    
    var latitude : Double = 0.0
    
    var longitude : Double = 0.0
    
    var subLocality : String = ""
    
    var locality : String = ""
    
    var administrativeArea : String = ""
    
    var postalCode : String = ""
    
    var country : String = ""
    
    var speed : Double = 0.0
    
    override init() {
        
    }
    
    init(dateTime: String, latitude: Double, longitude: Double, subLocality: String, locality: String, administrativeArea: String, postalCode: String, country: String, speed: Double) {
        self.dateTime = dateTime
        self.latitude = latitude
        self.longitude = longitude
        self.subLocality = subLocality
        self.locality = locality
        self.administrativeArea = administrativeArea
        self.postalCode = postalCode
        self.country = country
        self.speed = speed
    }
}

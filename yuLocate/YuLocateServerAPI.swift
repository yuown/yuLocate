//
//  YuLocateServerAPI.swift
//  yuLocate
//
//  Created by Yenkay on 17/01/15.
//  Copyright (c) 2015 yenkay. All rights reserved.
//

import UIKit
import GoogleMaps

protocol YuLocateServerAPIProtocol {
    
    func saveLocation(address: Address)
    
}


class YuLocateServerAPI:NSObject, NSURLConnectionDelegate {
    
    var yuDb = YuLocate.getInstance()
    
    var url = NSURL(string: "https://ovh.optumconnect.com/yuLocate/location")
    
    var start:NSDate!
    
    var data = NSMutableData()
    
    var userId = ""
    
    required override init() {
        super.init()
        userId = yuDb.getAllUsersFunc().0
    }
    
    struct Static {
        static var instance:YuLocateServerAPI? = nil
        static var token:dispatch_once_t = 0
    }
    
    class func getInstance() -> YuLocateServerAPI! {
        dispatch_once(&Static.token) {
            Static.instance = self()
        }
        return Static.instance!
    }
    
    func saveLocation(address: Address) {
        var request = NSMutableURLRequest()
        request.URL = NSURL(string: "https://ovh.optumconnect.com/yuLocate/location")
        request.HTTPMethod = "POST"
        var jData = address2Dictionary(address)
        yuDb.dblog("jData: \(jData)")
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(jData, options: nil, error: nil)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let urlConnection = NSURLConnection(request: request, delegate: self)
        urlConnection?.start()
        start=NSDate()
        //urlConnection?.start()
        //let task = NSURLSession.sharedSession().uploadTaskWithRequest(request,
            //fromData: address2Dictionary(address), completionHandler: )
        
        //task.resume()
        /*var session = NSURLSession.sharedSession()
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            println("Response: \(response)")
            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            println("Body: \(strData)")
            var err: NSError?
            var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? NSDictionary
            
            // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
            if(err != nil) {
                println(err!.localizedDescription)
                let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                println("Error could not parse JSON: '\(jsonStr)'")
            }
            else {
                // The JSONObjectWithData constructor didn't return an error. But, we should still
                // check and make sure that json has a value using optional binding.
                if let parseJSON = json {
                    // Okay, the parsedJSON is here, let's get the value for 'success' out of it
                    var success = parseJSON["success"] as? Int
                    println("Succes: \(success)")
                }
                else {
                    // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                    let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                    println("Error could not parse JSON: \(jsonStr)")
                }
            }
        })
        
        task.resume()
        yuDb.dblog("tsk.response: \(task.response)")*/
    }
    
    func saveLocation(location: CLLocation) {
        var request = NSMutableURLRequest()
//        request.set
        request.HTTPMethod = "POST"
        var jData = address2Dictionary(location)
        yuDb.dblog("jData: \(jData)")
        
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(jData, options: nil, error: nil)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let urlConnection = NSURLConnection(request: request, delegate: self)
        urlConnection?.start()
        start=NSDate()
        //let task = NSURLSession.sharedSession().uploadTaskWithRequest(request,
        //fromData: address2Dictionary(address), completionHandler: )
        
        //task.resume()
        /*var session = NSURLSession.sharedSession()
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            println("Response: \(response)")
            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            println("Body: \(strData)")
            var err: NSError?
            var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? NSDictionary
            
            // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
            if(err != nil) {
                println(err!.localizedDescription)
                let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                println("Error could not parse JSON: '\(jsonStr)'")
            }
            else {
                // The JSONObjectWithData constructor didn't return an error. But, we should still
                // check and make sure that json has a value using optional binding.
                if let parseJSON = json {
                    // Okay, the parsedJSON is here, let's get the value for 'success' out of it
                    var success = parseJSON["success"] as? Int
                    println("Succes: \(success)")
                }
                else {
                    // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                    let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                    println("Error could not parse JSON: \(jsonStr)")
                }
            }
        })
        
        task.resume()
        yuDb.dblog("tsk.response: \(task.response)")*/
    }
    
    func address2Dictionary(address:Address) -> NSDictionary {
        //var keys = ["dateTime", "latitude", "longitude", "subLocality", "locality", "administrativeArea", "postalCode", "country"]
        //var values = [address.dateTime, address.latitude, address.longitude, address.subLocality, address.locality, address.administrativeArea, address.postalCode, address.country]
        var data = ["dateTime": address.dateTime, "latitude": address.latitude, "longitude": address.longitude, "subLocality": address.subLocality, "locality": address.locality, "administrativeArea": address.administrativeArea, "postalCode": address.postalCode, "country": address.country, "userId": userId, "speed": address.speed]

        
        return data
    }
    
    func address2Dictionary(location:CLLocation) -> NSDictionary {
        var data = ["dateTime": yuDb.date2String(NSDate()), "latitude": location.coordinate.latitude, "longitude": location.coordinate.longitude, "userId": userId, "speed": location.speed]
        return data
    }
    
    func connection(connection:NSURLConnection!, didReceiveResponse response: NSURLResponse) {
        let status = (response as NSHTTPURLResponse).description
        self.data = NSMutableData()
    }
    
    func connection(connection: NSURLConnection, canAuthenticateAgainstProtectionSpace protectionSpace: NSURLProtectionSpace) -> Bool {
        return protectionSpace.authenticationMethod! == NSURLAuthenticationMethodServerTrust
    }
    
    func connection(connection: NSURLConnection, didReceiveAuthenticationChallenge challenge: NSURLAuthenticationChallenge) {
        if(challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust) {
            var creds = NSURLCredential(forTrust: challenge.protectionSpace.serverTrust)
            challenge.sender.useCredential(creds, forAuthenticationChallenge: challenge)
            challenge.sender.continueWithoutCredentialForAuthenticationChallenge(challenge)
        }
    }
    
    func connection(connection: NSURLConnection!, didReceiveData data: NSData!) {
        // Append the received chunk of data to our data object
        var str = NSString(data: data, encoding: NSUTF8StringEncoding)
        yuDb.dblog("str: \(str)")
    }
    
    /*func connectionDidFinishLoading(connection: NSURLConnection) {
        var err: NSError
        var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil)
        yuDb.dblog("Time: \(NSDate().timeIntervalSinceDate(start!))")
        if(jsonResult != nil) {
            var json = jsonResult as NSDictionary
            if json.count>0{
                var results: NSArray = json["results"] as NSArray
                yuDb.dblog("Res: \(results)")
            }
        }
    }*/
}
//
//  CurrentLocationController.swift
//  yuLocate
//
//  Created by Yenkay on 08/01/15.
//  Copyright (c) 2015 yenkay. All rights reserved.
//

import UIKit
import GoogleMaps

class CurrentLocationController:UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {
    
    var clientHelper = YuLocateClientHelper.getInstance()
    
    @IBOutlet var mapParentView: UIView!
    
    @IBOutlet var zoomBtn: UIButton!
    
    @IBOutlet var zoomSlider: UISlider!
    
    var start:NSDate?
    
    var data:NSMutableData!
    
    let kClientId = "39424579031-t23urr6vq9v2ck59oo0auu383nmv107t.apps.googleusercontent.com"
    
    var mapView : GMSMapView!
    
    var camera : GMSCameraPosition!
    
    var locationManager:CLLocationManager!
    
    var yuDb = YuLocate.getInstance()
    
    var geoCoder = GMSGeocoder()
    
    var server = YuLocateServerAPI.getInstance()
    
    //var canUpdateLocation = false
    
    var lastTimeStamp: NSDate!
    
    var lastLocation: CLLocation!
    
    var marker: GMSMarker!
    
    @IBOutlet var subView: UIView!
    
    var reminderController: ReminderController!
    
    @IBOutlet var tapper: UITapGestureRecognizer!
    
    var deferringUpdates = false
    
    var background = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        background = clientHelper.background
        
        let delegate = UIApplication.sharedApplication().delegate as AppDelegate
        delegate.currentLocationController = self
        locationManager = delegate.locationManager
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = CLActivityType.AutomotiveNavigation
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.delegate = self
        
        //locationManager.startUpdatingLocation()
        
        //if(background == 1) {
        //    locationManager.startMonitoringSignificantLocationChanges()
        //}

        camera = GMSCameraPosition.cameraWithLatitude(0, longitude: 0, zoom: 16)
        mapView = GMSMapView.mapWithFrame(self.mapParentView.bounds, camera: camera)

        mapView.myLocationEnabled = true
        mapView.delegate = self
        mapView.settings.myLocationButton = true
        //mapView.addGestureRecognizer(tapper)

        //self.view.userInteractionEnabled = true
        //self.mapParentView.userInteractionEnabled = true
        //self.mapView.userInteractionEnabled = true
        
        self.mapParentView.insertSubview(mapView, atIndex: 0)
        
        //self.mapView.contentMode = UIViewContentMode.ScaleToFill
        zoomSlider.value = 16
        
        //canUpdateLocation = true
        self.mapParentView.autoresizesSubviews = true
        self.mapView.autoresizingMask = (UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight | UIViewAutoresizing.FlexibleBottomMargin | UIViewAutoresizing.FlexibleRightMargin)
        
        marker = GMSMarker()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if(background == 1) {
            locationManager.requestAlwaysAuthorization()
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    @IBAction func zoomBtnAction(sender: UIButton) {
        zoomSlider.hidden = !zoomSlider.hidden
    }
    
    @IBAction func zoomSliderAction(sender: UISlider) {
        self.mapView.animateToZoom(zoomSlider.value)
    }
    
    @IBAction func zoomFinished(sender: UISlider) {
        zoomSlider.hidden = true
    }
    
    @IBAction func saveCurrentLocation(sender: UIButton) {
        //locationManager.startUpdatingLocation()
    }
    
    func mapView(mapView: GMSMapView!, willMove gesture: Bool) {
        zoomSlider.value = mapView.camera.zoom
        if(gesture == false) {
            // Location Change Triggered Automatically
            if(mapView.myLocation != nil) {
                //canUpdateLocation = true
                saveLocation2DB(mapView.myLocation)
            }
        } else {
            // User Dragged Maps Manually
            zoomSlider.hidden = true
            mapView.clear()
        }
    }
    
    func mapView(mapView: GMSMapView!, didLongPressAtCoordinate coordinate: CLLocationCoordinate2D) {
        marker.position = coordinate
        self.mapView.clear()
        marker.title = "Remind Me!"
        marker.snippet = "Create Reminder to reach this place at a later time"
        marker.map = self.mapView
        var update = GMSCameraUpdate.setTarget(coordinate, zoom: zoomSlider.value)
    }
    
    func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
        return false
    }
    
    func mapView(mapView: GMSMapView!, didTapInfoWindowOfMarker marker: GMSMarker!) {
        showSubView(marker)
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .Authorized {
            if background == 1 {
                locationManager.startMonitoringSignificantLocationChanges()
            } else {
                locationManager.startUpdatingLocation()
            }
        } else if status == .Denied {
            if background == 1 {
                locationManager.requestAlwaysAuthorization()
            } else {
                locationManager.requestWhenInUseAuthorization()
            }
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if let location = locations.first as? CLLocation {
            var update = GMSCameraUpdate.setTarget(location.coordinate, zoom: zoomSlider.value)
            mapView.moveCamera(update)
            saveLocation2DB(location)
            if(background == 1) {
                if(!self.deferringUpdates) {
                    NSLog("Deferring")
                    self.locationManager.allowDeferredLocationUpdatesUntilTraveled(0, timeout: 300)
                    //self.locationManager.stopUpdatingLocation()
                    //self.locationManager.stopMonitoringSignificantLocationChanges()
                    self.deferringUpdates = true
                } else {
                    locationManager.startMonitoringSignificantLocationChanges()
                    locationManager.startUpdatingLocation()
                }
            }
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFinishDeferredUpdatesWithError error: NSError!) {
        self.deferringUpdates = false
        NSLog("Deferring Stopped")
        /*if background == 1 {
            locationManager.startMonitoringSignificantLocationChanges()
        } else {
            locationManager.startUpdatingLocation()
        }*/
        //locationManager.startMonitoringSignificantLocationChanges()
        //locationManager.startUpdatingLocation()
    }
    
    func saveLocation2DB(location:CLLocation) {
        self.locationManager.stopUpdatingLocation()
        self.locationManager.stopMonitoringSignificantLocationChanges()
        //canUpdateLocation = false
        if(lastLocation != nil && (lastLocation.coordinate.latitude == location.coordinate.latitude && lastLocation.coordinate.longitude == location.coordinate.longitude)) {
            yuDb.dblog("Location Duplicated, Not Saving")
            return
        }
        
        lastLocation = location
        lastTimeStamp = location.timestamp
        
        var valLats  = clientHelper.mapLats2Addr
        var valSync = clientHelper.syncWithServer
        if(valLats == 1) {
            geoCoder.reverseGeocodeCoordinate(location.coordinate, completionHandler: { response, error -> Void in
                if(response != nil && response.results() != nil) {
                    var gmsAddress = response.results().first as GMSAddress
                    var address = Address(
                        dateTime: "",
                        latitude: gmsAddress.coordinate.latitude,
                        longitude: gmsAddress.coordinate.longitude,
                        subLocality: gmsAddress.subLocality == nil ? "" : gmsAddress.subLocality,
                        locality: gmsAddress.locality == nil ? "" : gmsAddress.locality,
                        administrativeArea: gmsAddress.administrativeArea == nil ? "" : gmsAddress.administrativeArea,
                        postalCode: gmsAddress.postalCode == nil ? "" : gmsAddress.postalCode == nil ? "" : gmsAddress.postalCode,
                        country: gmsAddress.country == nil ? "" : gmsAddress.country,
                        speed: location.speed
                    )
                    self.yuDb.saveCurrentLocation2DB(address)
                    if(valSync == 1) {
                        self.server.saveLocation(address)
                    }

                } else {
                    self.yuDb.saveCurrentLocation2DB(location)
                    if(valSync == 1) {
                        self.server.saveLocation(location)
                    }
                }
            })
        } else {
            self.yuDb.saveCurrentLocation2DB(location)
            if(valSync == 1) {
                self.server.saveLocation(location)
            }
        }
    }

    @IBAction func tappedOutside(sender: UITapGestureRecognizer) {
        yuDb.dblog("Tapped")
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        yuDb.dblog("viewWillTransitionToSize")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        yuDb.dblog("viewWillAppear")
        
    }
    
    func showCustomLocationOnMap(address: Address) {
        hideSubView(true)
        var location = CLLocationCoordinate2D(latitude: address.latitude as CLLocationDegrees, longitude: address.longitude as CLLocationDegrees)
        marker.position = location
        
        mapView.clear()
        var title = ""
        if(address.subLocality != "") {
            title = address.subLocality
        } else if(address.locality != "") {
            title = address.locality
        } else if(address.administrativeArea != "") {
            title = address.administrativeArea
        } else {
            title = "\(address.latitude), \(address.longitude)"
        }
        
        marker.title = title
        marker.snippet = address.dateTime
        marker.map = mapView
        var update = GMSCameraUpdate.setTarget(location, zoom: zoomSlider.value)
        mapView.moveCamera(update)
    }
    
    func showSubView(marker: GMSMarker) {
        subView.hidden = false
        subView.layer.cornerRadius = 20
        subView.layer.masksToBounds = true
        subView.layer.shadowColor = UIColor.redColor().CGColor;
        subView.layer.shadowOffset = CGSizeMake(0, 5);
        subView.layer.shadowOpacity = 0.6;
        subView.layer.shadowRadius = 10.0;
        
        reminderController.setData(marker.position.latitude as Double, longitude: marker.position.longitude as Double)
        self.mapView.userInteractionEnabled = false
    }
    
    func hideSubView(clearMarker: Bool) {
        subView.hidden = true
        self.mapView.userInteractionEnabled = true
        if(clearMarker) {
            mapView.clear()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "go2remind") {
            self.reminderController = segue.destinationViewController as ReminderController
        }
    }
}
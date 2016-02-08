//
//  LocationManager.swift
//  MMChat
//
//  Created by Kostya Grischenko on 1/18/16.
//  Copyright © 2016 Kostya Grishchenko. All rights reserved.
//

import UIKit
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    static let sharedInstance = LocationManager()
    
    private var locationManager = CLLocationManager()
    private var locationHandler : ((CLLocation) -> Void)?
    
    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
    }
    
    func getLocation(handler: ((CLLocation) -> Void)?) {
        if handler != nil {
            locationHandler = handler
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = manager.location {
            if locationHandler != nil {
                locationHandler!(location)
                locationHandler = nil
            }
        }
        locationManager.stopUpdatingLocation()
    }

    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        locationManager.stopUpdatingLocation()
        print("\(error.localizedFailureReason, error.localizedDescription)")
    }
}

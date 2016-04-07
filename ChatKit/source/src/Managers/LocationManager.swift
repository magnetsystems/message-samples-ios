/*
 * Copyright (c) 2016 Magnet Systems, Inc.
 * All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you
 * may not use this file except in compliance with the License. You
 * may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
 * implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */

import CoreLocation
import UIKit

public class LocationManager: NSObject, CLLocationManagerDelegate {
    
    
    //MARK: Static properties
    
    
    public static let sharedInstance = LocationManager()
    
    
    //MARK: Public properties
    
    
    public var onAuthorizationUpdate : (() -> Void)?
    
    
    //MARK: Private properties
    
    
    private var locationHandler : ((CLLocation) -> Void)?
    private var locationManager = CLLocationManager()
    
    
    //MARK: Overrides
    
    
    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    public func canLocationServicesBeEnabled() -> Bool {
        var myDict: NSDictionary?
        if let path = NSBundle.mainBundle().pathForResource("Info", ofType: "plist") {
            myDict = NSDictionary(contentsOfFile: path)
        }
        if myDict?["NSLocationWhenInUseUsageDescription"] != nil {
            return true
        }
        
        return false
    }
    
    public func isLocationServicesEnabled() -> Bool {
        
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .NotDetermined, .Restricted, .Denied:
                return false
            case .AuthorizedAlways, .AuthorizedWhenInUse:
                return true
            }
        }
        
        return false
    }
    
    //MARK: - Public implementation
    
    
    public func getLocation(handler: ((CLLocation) -> Void)?) {
        if handler != nil {
            locationHandler = handler
            locationManager.startUpdatingLocation()
        }
    }
    
    public func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        self.onAuthorizationUpdate?()
    }
    
    public func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        locationManager.stopUpdatingLocation()
        print("\(error.localizedFailureReason, error.localizedDescription)")
    }
    
    public func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = manager.location {
            if locationHandler != nil {
                locationHandler!(location)
                locationHandler = nil
            }
        }
        locationManager.stopUpdatingLocation()
    }
    
}

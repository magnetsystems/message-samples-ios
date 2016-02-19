/*
* Copyright (c) 2015 Magnet Systems, Inc.
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

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    
    //MARK: Static properties
    
    
    static let sharedInstance = LocationManager()
    
    
    //MARK: Private properties
    
    
    private var locationHandler : ((CLLocation) -> Void)?
    private var locationManager = CLLocationManager()
    
    
    //MARK: Overrides
    
    
    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
    }
    
    
    //MARK: - Public implementation
    
    
    func getLocation(handler: ((CLLocation) -> Void)?) {
        if handler != nil {
            locationHandler = handler
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        locationManager.stopUpdatingLocation()
        print("\(error.localizedFailureReason, error.localizedDescription)")
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
    
}

//
//  WeatherService.swift
//  SmartShopper
//
//  Created by Pritesh Shah on 9/17/15.
//  Copyright © 2015 Magnet Systems, Inc. All rights reserved.
//

import Foundation
import Alamofire
import Argo
import CoreLocation

public class WeatherService {
    
    // FIXME: Hardcoded API KEY, replace with your own!
    static let apiKey = "d74d8ebc1cffe954"
    static let baseURL = "https://api.wunderground.com/api/" + apiKey
    
    func conditions(location: CLLocation, success: (WeatherConditions -> Void)?, failure: (ErrorType? -> Void)?) -> Void {
        
        Alamofire.request(.GET, WeatherService.baseURL + "/conditions/q/\(location.coordinate.latitude),\(location.coordinate.longitude).json", parameters: nil)
                .responseJSON { (_, _, result) -> Void in
                    if result.isSuccess {
                        if let j = result.value {
                            let conditions: WeatherConditions? = decode(j)
                            success?(conditions!)
                        }
                    } else if result.isFailure {
                        failure?(result.error)
                    }
                }
    }
    
}
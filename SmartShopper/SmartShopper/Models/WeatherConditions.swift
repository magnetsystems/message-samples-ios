//
//  WeatherCondition.swift
//  SmartShopper
//
//  Created by Pritesh Shah on 9/17/15.
//  Copyright © 2015 Magnet Systems, Inc. All rights reserved.
//

import Foundation
import Argo
//import Runes

/* Sample JSON response
{
    "response": {
    },
    "current_observation": {
        "display_location": {
            "city":"San Francisco",
            "state":"CA",
            "country":"US",
            "temp_f":66.6,
            "temp_c":19.2
        }
    }
}
*/
public struct WeatherConditions {
    let city: String
    let state: String
    let country: String
    let temperatureInCelsius: Double
    let temperatureInFahrenheit: Double
}

extension WeatherConditions: CustomStringConvertible {
    public var description : String {
        return "city: \(city), state: \(state), country: \(country), temperature: \(temperatureInFahrenheit) F"
    }
}

extension WeatherConditions: Decodable {
    
    static func create(city: String)(state: String)(country: String)(temperatureInCelsius: Double)(temperatureInFahrenheit: Double) -> WeatherConditions {
        return WeatherConditions(city: city, state: state, country: country, temperatureInCelsius: temperatureInCelsius, temperatureInFahrenheit: temperatureInFahrenheit)
    }
    
    public static func decode(j: JSON) -> Decoded<WeatherConditions> {
        return WeatherConditions.create
            <^> j <| ["current_observation", "display_location", "city"]
            <*> j <| ["current_observation", "display_location", "state"]
            <*> j <| ["current_observation", "display_location", "country"]
            <*> j <| ["current_observation", "temp_c"]
            <*> j <| ["current_observation", "temp_f"]
    }
}

//
//  ProductService.swift
//  SmartShopper
//
//  Created by Pritesh Shah on 9/17/15.
//  Copyright © 2015 Magnet Systems, Inc. All rights reserved.
//

import Foundation
import Alamofire
import Argo
import CoreLocation

public class ProductService {
    
    // FIXME: Hardcoded API KEY, replace with your own!
    static let apiKey = "3rvmgxy7e27j9vtw6f6kqxbn"
    static let baseURL = "https://api.walmartlabs.com/v1"
    
    func products(query: String, success: ([Product] -> Void)?, failure: (ErrorType? -> Void)?) -> Void {
        
        let parameters = [
            "query": query,
            "format": "json",
            "apiKey": ProductService.apiKey
        ]
        
        
        Alamofire.request(.GET, ProductService.baseURL + "/search", parameters: parameters)
            .responseJSON { (_, _, result) -> Void in
                if result.isSuccess {
                    if let j = result.value {
                        let products: [Product]? = decode(j["items"]!!)
                        success?(products!)
                    }
                } else if result.isFailure {
                    failure?(result.error)
                }
        }
    }
    
}

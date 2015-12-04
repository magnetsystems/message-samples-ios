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

import Foundation

@objc public class MMURLProtocol: NSURLProtocol {
    
    public static let protocolKey = "MMURLProtocolKey"
    public static let cacheAgeKey = "MMURLCacheAgeKey"
    public static let timestampKey = "MMURLCacheTimestampKey"
    
    var data: NSData!
    var response: NSURLResponse!
    lazy var session: NSURLSession = {
            return NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        }()
    var sessionTask: NSURLSessionDataTask!
    
    override public class func canInitWithRequest(request: NSURLRequest) -> Bool {

        // If caching is not enabled, leave it alone!
        if cacheAgeForRequest(request) == nil {
            return false
        }
        
        if NSURLProtocol.propertyForKey(MMURLProtocol.protocolKey, inRequest: request) != nil {
            return false
        }
        
        return true
    }
    
    override public class func canonicalRequestForRequest(request: NSURLRequest) -> NSURLRequest {
        return request
    }
    
    override public class func requestIsCacheEquivalent(a: NSURLRequest, toRequest b: NSURLRequest) -> Bool {
        return super.requestIsCacheEquivalent(a, toRequest:b)
    }
    
    override public func startLoading() {
        
        var response: NSCachedURLResponse?
        if let cachedResponse = NSURLCache.sharedURLCache().cachedResponseForRequest(request) {
            
            if let userInfo = cachedResponse.userInfo {
                
                if let cacheDate = userInfo[MMURLProtocol.timestampKey] as! NSDate? {
                    
                    if cacheDate.timeIntervalSinceNow < -(MMURLProtocol.cacheAgeForRequest(request)!) {
                        // Remove older cache?
                    } else {
                        response = cachedResponse
                    }
                }
            }
        }
        
        if let cachedResponse = response {
//            print("Cache hit: \(request)")
            self.client!.URLProtocol(self, didReceiveResponse: cachedResponse.response, cacheStoragePolicy: .NotAllowed)
            self.client!.URLProtocol(self, didLoadData: cachedResponse.data)
            self.client!.URLProtocolDidFinishLoading(self)
        } else {
            let newRequest = self.request.mutableCopy() as! NSMutableURLRequest
            NSURLProtocol.setProperty(true, forKey: MMURLProtocol.protocolKey, inRequest: newRequest)
            sessionTask = session.dataTaskWithRequest(newRequest, completionHandler: {(data, response, error) in
                
                if error != nil {
                    self.client!.URLProtocol(self, didFailWithError: error!)
                } else {
                    self.response = response
                    self.data = data
                    self.saveCachedResponse()
                    
                    self.client!.URLProtocol(self, didReceiveResponse: response!, cacheStoragePolicy: .NotAllowed)
                    self.client!.URLProtocol(self, didLoadData: data!)
                    self.client!.URLProtocolDidFinishLoading(self)
                }
                
            });
            sessionTask.resume()
        }
    }
    
    override public func stopLoading() {
        session.finishTasksAndInvalidate()
        sessionTask?.cancel()
    }
    
    func saveCachedResponse () {
        print("Saving cached response")
        
        // Timestamp the cache entry
        let userInfo = [MMURLProtocol.timestampKey: NSDate()]
        let cachedResponse = NSCachedURLResponse(response:response, data:data, userInfo:userInfo, storagePolicy: .Allowed)
        
        NSURLCache.sharedURLCache().storeCachedResponse(cachedResponse, forRequest: request)
    }
    
    class func cacheAgeForRequest(request: NSURLRequest) -> NSTimeInterval? {
        return NSURLProtocol.propertyForKey(MMURLProtocol.cacheAgeKey, inRequest: request) as! NSTimeInterval?
    }
}
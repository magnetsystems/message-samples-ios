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

import AFNetworking

enum AuthenticationErrorType: String {
    case InvalidClientCredentials = "client_credentials"
    case ExpiredCATToken = "client_access_token"
    case ExpiredHATToken = "user_access_token"
    case InvalidRefreshToken = "refresh_token" // Refresh token is (not valid|has expired|not valid for this device)
}

public class MMHTTPSessionManager: AFHTTPSessionManager {
    
    public init(baseURL url: NSURL?, sessionConfiguration configuration: NSURLSessionConfiguration?, serviceAdapter: MMServiceAdapter) {
        self.serviceAdapter = serviceAdapter
        super.init(baseURL: url, sessionConfiguration: configuration)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public unowned var serviceAdapter: MMServiceAdapter
    
    override public func dataTaskWithRequest(request: NSURLRequest, completionHandler originalCompletionHandler: ((NSURLResponse, AnyObject?, NSError?) -> Void)?) -> NSURLSessionDataTask {
        
        let completionHandler = { (response: NSURLResponse, responseObject: AnyObject?, error: NSError?) in
            guard let URLResponse = response as? NSHTTPURLResponse else {
                // FIXME: Log this error
                originalCompletionHandler?(response, responseObject, error)
                print("Could not cast response to NSHTTPURLResponse")
                return
//                fatalError("Could not cast response to NSHTTPURLResponse")
            }
            if URLResponse.statusCode == 401 {
                if let wwwAuthenticateHeader = URLResponse.allHeaderFields["WWW-Authenticate"] as? String {
                    let token = "error=\""
                    let firstError = wwwAuthenticateHeader.characters.split(",").map { String($0) }.filter { $0.hasPrefix(token) }.first
                    if let e = firstError {
                        let errorType = e.substringWithRange(Range<String.Index>(start: e.startIndex.advancedBy(token.characters.count), end: e.endIndex.advancedBy(-1)))
                        if let authenticationErrorType = AuthenticationErrorType(rawValue: errorType) {
                            switch authenticationErrorType {
                            case .InvalidClientCredentials:
                                self.serviceAdapter.CATToken = nil
                                assert(false, "An invalid set of clientID/clientSecret are used to configure MagnetMax. Please check them again.")
                                NSNotificationCenter.defaultCenter().postNotificationName(MMServiceAdapterDidReceiveInvalidCATTokenNotification, object: nil)
                            case .ExpiredCATToken:
//                                print(request)
                                self.serviceAdapter.authenticateApplicationWithSuccess({
                                    let requestWithNewToken = request.mutableCopy() as! NSMutableURLRequest
                                    requestWithNewToken.setValue(self.serviceAdapter.bearerAuthorization(), forHTTPHeaderField: "Authorization")
                                    let originalTask = super.dataTaskWithRequest(requestWithNewToken, completionHandler: originalCompletionHandler)
                                    originalTask.resume()
                                }) { error in
                                    print(error)
                                    originalCompletionHandler?(response, responseObject, error)
                                }
                            case .ExpiredHATToken:
//                                print(request)
                                if self.serviceAdapter.refreshToken != nil {
                                    self.serviceAdapter.authenticateUserWithSuccess({
                                        let requestWithNewToken = request.mutableCopy() as! NSMutableURLRequest
                                        requestWithNewToken.setValue(self.serviceAdapter.bearerAuthorization(), forHTTPHeaderField: "Authorization")
                                        let originalTask = super.dataTaskWithRequest(requestWithNewToken, completionHandler: originalCompletionHandler)
                                        originalTask.resume()
                                    }, failure: { error in
                                        print(error)
                                        originalCompletionHandler?(response, responseObject, error)
                                    })
                                } else {
                                    originalCompletionHandler?(response, responseObject, error)
                                }
                            case .InvalidRefreshToken:
//                                print(request)
                                self.serviceAdapter.HATToken = nil
                                originalCompletionHandler?(response, responseObject, error)
                            }
                        } else {
                            // TODO: Log error
                            // This is possible if the server is not able to decrypt our access token.
                            // Perhaps, the salt changed since the server was rebuilt?
                            self.serviceAdapter.CATToken = nil
                            self.serviceAdapter.HATToken = nil
                            
                            self.serviceAdapter.authenticateApplicationWithSuccess({
                                let requestWithNewToken = request.mutableCopy() as! NSMutableURLRequest
                                requestWithNewToken.setValue(self.serviceAdapter.bearerAuthorization(), forHTTPHeaderField: "Authorization")
                                let originalTask = super.dataTaskWithRequest(requestWithNewToken, completionHandler: originalCompletionHandler)
                                originalTask.resume()
                            }) { error in
                                print(error)
                                originalCompletionHandler?(response, responseObject, error)
                            }
                        }
                    }
                }
            } else {
                originalCompletionHandler?(response, responseObject, error)
            }
            
        }
        
        let task = super.dataTaskWithRequest(request, completionHandler: completionHandler)
        
        return task
    }
    
}

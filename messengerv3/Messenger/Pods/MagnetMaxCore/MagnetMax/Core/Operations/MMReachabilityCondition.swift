/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
This file shows an example of implementing the OperationCondition protocol.
*/

import Foundation
import AFNetworking

/**
    This is a condition that performs a very high-level reachability check.
    It does *not* perform a long-running reachability check, nor does it respond to changes in reachability.
    Reachability is evaluated once when the operation to which this is attached is asked about its readiness.
*/
public struct MMReachabilityCondition: OperationCondition {
    static let hostKey = "Host"
    public static let name = "MMReachability"
    public static let isMutuallyExclusive = false
    
    let reachabilityController: MMReachabilityController
    
    
    public init() {
        self.reachabilityController = MMReachabilityController()
    }
    
    public func dependencyForOperation(operation: Operation) -> NSOperation? {
        return nil
    }
    
    public func evaluateForOperation(operation: Operation, completion: OperationConditionResult -> Void) {
        switch reachabilityController.status {
        case .ReachableViaWiFi, .ReachableViaWWAN:
            completion(.Satisfied)
            NSNotificationCenter.defaultCenter().removeObserver(reachabilityController)
        default:
            reachabilityController.completionHandler = completion
            NSNotificationCenter.defaultCenter().addObserver(reachabilityController, selector: "reachabilityChangeReceived:", name: AFNetworkingReachabilityDidChangeNotification, object: nil)
        }
    }
}

@objc public class MMReachabilityController: NSObject {
    var completionHandler : (OperationConditionResult -> Void)?
    var status: AFNetworkReachabilityStatus = AFNetworkReachabilityStatus.Unknown
    
    func reachabilityChangeReceived(notification: NSNotification) {
        let userInfo = notification.userInfo as! [String: NSNumber]
        let statusNumber = userInfo[AFNetworkingReachabilityNotificationStatusItem]
        status = AFNetworkReachabilityStatus(rawValue: (statusNumber?.integerValue)!)!
        if status == .ReachableViaWiFi || status == .ReachableViaWWAN {
            completionHandler?(.Satisfied)
        }
    }
}
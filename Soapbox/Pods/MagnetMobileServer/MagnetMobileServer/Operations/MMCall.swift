/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
This file contains the code to download the feed of recent earthquakes.
*/

import Foundation
import AFNetworking
import Mantle

public class MMCall: GroupOperation {
    // MARK: Properties
    
    /**
     * A system-generated unique ID for this call.
     */
    let callID: String
    let serviceAdapter: MMServiceAdapter
    let serviceMethod: MMServiceMethod
    let request: NSMutableURLRequest
    var successBlock: AnyObject?
    var failureBlock: ((NSError) -> Void)?
    /**
     * Should the mock implementation be used?
     */
    public var useMock: Bool = false
    var underlyingOperation: NSOperation? = nil
    private var cacheOptions: MMCacheOptions? = nil
    private var reliableCallOptions: MMReliableCallOptions? = nil
    
    // MARK: Initialization
    
    public init(callID: String, serviceAdapter: MMServiceAdapter, serviceMethod: MMServiceMethod, request: NSMutableURLRequest, underlyingOperation: NSOperation?) {
        self.callID = callID
        self.serviceAdapter = serviceAdapter
        self.serviceMethod = serviceMethod
        self.request = request
        self.underlyingOperation = underlyingOperation
        super.init(operations: [])
        name = "\(MMStringFromRequestMethod(serviceMethod.requestMethod)) \(serviceMethod.path)"
    }
    
    public init(callID: String, serviceAdapter: MMServiceAdapter, serviceMethod: MMServiceMethod, request: NSMutableURLRequest, successBlock: AnyObject?, failureBlock: ((NSError) -> Void)?) {
        self.callID = callID
        self.serviceAdapter = serviceAdapter
        self.serviceMethod = serviceMethod
        self.request = request
        self.successBlock = successBlock
        self.failureBlock = failureBlock
        super.init(operations: [])
        name = "\(MMStringFromRequestMethod(serviceMethod.requestMethod)) \(serviceMethod.path)"
    }
    
    public func executeEventually(reliableCallOptions: MMReliableCallOptions?) {
        self.reliableCallOptions = reliableCallOptions
        serviceAdapter.requestOperationManager.operationQueue.addOperation(self)
    }
    
    public func executeInBackground(cacheOptions: MMCacheOptions?) {
        self.cacheOptions = cacheOptions
        serviceAdapter.requestOperationManager.operationQueue.addOperation(self)
    }
    
    override func execute() {
        
        let isReachable = serviceAdapter.sessionManager.reachabilityManager.reachable
        let useCache = (cacheOptions != nil)
        let isReliable = (reliableCallOptions != nil)
        
        if underlyingOperation == nil {
            // Modify URL for mock requests: /api/ becomes /mock/api/
            if (useMock) {
                let URLString = request.URL?.absoluteString
                guard var URL = URLString else {
                    // TODO: Log errror!
                    return
                }
                URL = URL.stringByReplacingOccurrencesOfString("/api/", withString: "/mock/api/")
                request.URL = NSURL(string: URL)
            }
            
            if useCache {
                let validMethods : MMRequestMethod = [.GET, .HEAD, .OPTIONS]
                let doesMethodSupportCaching = validMethods.contains(serviceMethod.requestMethod)
                assert(doesMethodSupportCaching, "Caching is only supported for calls with the following HTTP methods: HEAD, GET and OPTIONS.")
                
                var maxCacheAge = cacheOptions!.maxCacheAge
                
                if !isReachable && useCache && cacheOptions!.alwaysUseCacheIfOffline {
                    maxCacheAge = NSDate().timeIntervalSince1970
                }
                
                // Mark the request as cacheable
                NSURLProtocol.setProperty(maxCacheAge, forKey: MMURLProtocol.cacheAgeKey, inRequest: request)
            }
            
            request.setValue(serviceAdapter.bearerAuthorization(), forHTTPHeaderField: "Authorization")
            
            var reliableCall: MMReliableCall?
            
            if isReliable {
                let validMethods : MMRequestMethod = [.POST, .PUT, .DELETE, .PATCH]
                let doesMethodSupportReliability = validMethods.contains(serviceMethod.requestMethod)
                assert(doesMethodSupportReliability, "Only calls with the HTTP methods: POST, PUT, DELETE and PATCH can be made reliable.")
                
                MMCoreDataStack.sharedContext.performChanges({ () -> () in
                    reliableCall = MMReliableCall.insertIntoContext(MMCoreDataStack.sharedContext, callID: self.callID, clazz: NSStringFromClass(self.serviceMethod.clazz), method: NSStringFromSelector(self.serviceMethod.selector), request: self.request, response: nil)
                })
            }
            
            underlyingOperation = serviceAdapter.requestOperationManager.requestOperationWithRequest(request, success: { (URLResponse, responseObject) -> Void in
                
                if isReliable {
                    MMCoreDataStack.sharedContext.performChanges{
                        reliableCall?.response = URLResponse
                    }
                }
                
                if self.successBlock != nil {
                    var response: AnyObject!
                    var responseString: String!
                    if let _ = responseObject as? NSDictionary  {
                        response = responseObject["value"]
                    } else if let _ = responseObject as? NSData  {
                        let formatter = NSNumberFormatter()
                        responseString = NSString(data: responseObject as! NSData, encoding: NSUTF8StringEncoding) as! String
                        response = formatter.numberFromString(responseString)
                    } else if let _ = responseObject as? NSString  {
                        let formatter = NSNumberFormatter()
                        responseString = responseObject as! String
                        response = formatter.numberFromString(responseString)
                    }
                    
                    switch self.serviceMethod.returnType {
                    case .Void:
                        typealias SuccessBlock = @convention(block) (AnyObject?) -> ()
                        let successBlock = unsafeBitCast(self.successBlock, SuccessBlock.self)
                        successBlock(nil)
                    case .String:
                        typealias SuccessBlock = @convention(block) (String) -> ()
                        let successBlock = unsafeBitCast(self.successBlock, SuccessBlock.self)
                        successBlock(responseString)
                    case .Enum:
                        typealias SuccessBlock = @convention(block) (UInt) -> ()
                        let successBlock = unsafeBitCast(self.successBlock, SuccessBlock.self)
                        // FIXME: Hack - Server returns a double-quoted string.
                        if responseString.hasPrefix("\"") && responseString.hasSuffix("\"") {
                            responseString = responseString.substringWithRange(Range<String.Index>(start: responseString.startIndex.advancedBy(1), end:responseString.endIndex.advancedBy(-1)))
                        }
                        let enumValue = MMValueTransformer.enumTransformerForContainerClass(self.serviceMethod.returnTypeClass).transformedValue(responseString)?.unsignedIntegerValue
                        // unsignedIntegerValue is supposed to return an UInt, but Xcode 7.0 thinks it returns an Int. Weird!
                        successBlock(UInt(enumValue!))
                        
                    case .Boolean:
                        typealias SuccessBlock = @convention(block) (Bool) -> ()
                        let successBlock = unsafeBitCast(self.successBlock, SuccessBlock.self)
                        // FIXME: Can we modify the transformer instead?
                        let boolValue = MMValueTransformer.booleanTransformer().transformedValue(NSNumber(bool: (responseString == "true")))?.boolValue
                        successBlock(boolValue!)
                        
                    case .Char:
                        typealias SuccessBlock = @convention(block) (Int) -> ()
                        let successBlock = unsafeBitCast(self.successBlock, SuccessBlock.self)
                        successBlock(response.integerValue!)
                        
                    case .Unichar:
                        typealias SuccessBlock = @convention(block) (UInt16) -> ()
                        let successBlock = unsafeBitCast(self.successBlock, SuccessBlock.self)
                        let unicharValue = MMValueTransformer.unicharTransformer().transformedValue(responseString)?.unsignedShortValue
                        successBlock(unicharValue!)
                        
                    case .Short, .Integer:
                        typealias SuccessBlock = @convention(block) (Int) -> ()
                        let successBlock = unsafeBitCast(self.successBlock, SuccessBlock.self)
                        successBlock(response.integerValue)
                        
                    case .LongLong:
                        typealias SuccessBlock = @convention(block) (CLongLong) -> ()
                        let successBlock = unsafeBitCast(self.successBlock, SuccessBlock.self)
                        let value = MMValueTransformer.longLongTransformer().transformedValue(response)?.longLongValue
                        successBlock(value!)
                        
                    case .Float:
                        typealias SuccessBlock = @convention(block) (Float) -> ()
                        let successBlock = unsafeBitCast(self.successBlock, SuccessBlock.self)
                        successBlock(Float(responseString)!)
                        
                    case .Double:
                        typealias SuccessBlock = @convention(block) (Double) -> ()
                        let successBlock = unsafeBitCast(self.successBlock, SuccessBlock.self)
                        successBlock(Double(responseString)!)
                        
                    case .BigDecimal: break
                    case .BigInteger:
                        typealias SuccessBlock = @convention(block) (NSDecimalNumber) -> ()
                        let successBlock = unsafeBitCast(self.successBlock, SuccessBlock.self)
                        successBlock(NSDecimalNumber(string: responseString))
                        
                    case .Date:
                        typealias SuccessBlock = @convention(block) (NSDate) -> ()
                        let successBlock = unsafeBitCast(self.successBlock, SuccessBlock.self)
                        let value = MMValueTransformer.dateTransformer().transformedValue(responseString)
                        successBlock(value as! NSDate)
                        
                    case .Uri:
                        typealias SuccessBlock = @convention(block) (NSURL) -> ()
                        let successBlock = unsafeBitCast(self.successBlock, SuccessBlock.self)
                        let value = MMValueTransformer.urlTransformer().transformedValue(responseString)
                        successBlock(value as! NSURL)
                        
                    case .MagnetNode, .Array:
                        typealias SuccessBlock = @convention(block) (AnyObject) -> ()
                        let successBlock = unsafeBitCast(self.successBlock, SuccessBlock.self)
                        var res: AnyObject
                        if responseObject as? NSDictionary != nil || responseObject as? NSArray != nil  {
                            res = responseObject
                        } else {
                            do {
                                try res = AFJSONResponseSerializer().responseObjectForResponse(URLResponse, data: responseObject as? NSData)
                                if self.serviceMethod.returnTypeClass != nil {
                                    if let _ = res as? NSArray  {
                                        res = MMValueTransformer.listTransformerForType(self.serviceMethod.returnComponentType, clazz: self.serviceMethod.returnTypeClass).transformedValue(res)!
                                    } else if let _ = res as? NSDictionary  {
                                        try res = MTLJSONAdapter.modelOfClass(self.serviceMethod.returnTypeClass, fromJSONDictionary: res as! [NSObject : AnyObject])
                                    }
                                    successBlock(res)
                                } else {
                                    if self.serviceMethod.returnType == MMServiceIOType.Array {
                                    }
                                    successBlock(res);
                                }
                            } catch let error as NSError {
                                self.aggregateError(error)
                                self.failureBlock?(error)
                            }
                        }
                        
                    case .Dictionary:
                        typealias SuccessBlock = @convention(block) (NSDictionary) -> ()
                        let successBlock = unsafeBitCast(self.successBlock, SuccessBlock.self)
                        var res: AnyObject
                        if responseObject as? NSDictionary != nil {
                            res = responseObject
                        } else {
                            do {
                                try res = AFJSONResponseSerializer().responseObjectForResponse(URLResponse, data: responseObject as? NSData)
                                if self.serviceMethod.returnTypeClass != nil {
                                    res = MMValueTransformer.mapTransformerForType(self.serviceMethod.returnComponentType, clazz: self.serviceMethod.returnTypeClass).transformedValue(res)!
                                }
                                successBlock(res as! NSDictionary)
                            } catch let error as NSError {
                                self.aggregateError(error)
                                self.failureBlock?(error)
                            }
                        }
                        
                    case .Data:
                        typealias SuccessBlock = @convention(block) (NSData) -> ()
                        let successBlock = unsafeBitCast(self.successBlock, SuccessBlock.self)
                        let value = MMValueTransformer.dataTransformer().transformedValue(response)
                        successBlock(value as! NSData)
                        
                    case .Bytes: break
                    }
                }
                }) { error -> Void in
                    self.failureBlock?(error)
            }
        }
        
        if isReliable {
            let reachabilityCondition = MMReachabilityCondition()
            (underlyingOperation as! Operation).addCondition(reachabilityCondition)
        }
        
        if let op = underlyingOperation {
            addOperation(op)
        }
        
        super.execute()
    }
    
    public func addCondition(condition: MMCondition) {
//        print("condition.dynamicType = \(condition.dynamicType)")
        let operationCondition = OperationConditionImplementer(condition: condition)
        addCondition(operationCondition)
    }
}

struct OperationConditionImplementer/*<T: MMCondition>*/: OperationCondition {
//    let condition: T
    let condition: MMCondition
    
    static var name: String {
//        return "Silent<\(T.name)>"
        return "OperationConditionImplementer"
    }
    
    static var isMutuallyExclusive: Bool {
//        return T.isMutuallyExclusive
        return false
    }
    
    func dependencyForOperation(operation: Operation) -> NSOperation? {
        return condition.dependencyForOperation(operation)
    }
    
    func evaluateForOperation(operation: Operation, completion: OperationConditionResult -> Void) {
        condition.evaluateForOperation(operation) { error -> Void in
            if error != nil {
                completion(.Failed(error!))
            } else {
                completion(.Satisfied)
            }
        }
    }
    init(condition: /*T*/MMCondition) {
        self.condition = condition
    }
}

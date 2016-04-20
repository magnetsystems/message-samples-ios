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

@objc public class MMXPayloadRegister : NSObject {
    internal static var contentType = [String : MMXPayload.Type]()
    internal static var lock = NSLock()
    
    public static func classForContentType(contentType : String) -> MMXPayload.Type? {
        return self.contentType[contentType]
    }
    
    public static func registerClassForPayloads(rclass : MMXPayload.Type) {
        lock.lock()
        contentType[rclass.contentType] = rclass
        lock.unlock()
    }
}

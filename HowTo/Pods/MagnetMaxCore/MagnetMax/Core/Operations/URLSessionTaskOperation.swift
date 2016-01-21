/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
Shows how to lift operation-like objects in to the NSOperation world.
*/

import Foundation

private var URLSessionTaksOperationKVOContext = 0

/**
    `URLSessionTaskOperation` is an `Operation` that lifts an `NSURLSessionTask`
    into an operation.

    Note that this operation does not participate in any of the delegate callbacks \
    of an `NSURLSession`, but instead uses Key-Value-Observing to know when the
    task has been completed. It also does not get notified about any errors that
    occurred during execution of the task.

    An example usage of `URLSessionTaskOperation` can be seen in the `DownloadEarthquakesOperation`.
*/
// Includes a fix from here: https://github.com/pluralsight/PSOperations/pull/24/files#diff-086cc60d8fd6d7e2b0102a0c2036e30e
public class URLSessionTaskOperation: Operation {
    let task: NSURLSessionTask
    
    private var observerRemoved = false
    private let stateLock = NSLock()
    
    public init(task: NSURLSessionTask) {
        assert(task.state == .Suspended, "Tasks must be suspended.")
        self.task = task
        super.init()
    }
    
    override func execute() {
        assert(task.state == .Suspended, "Task was resumed by something other than \(self).")

        task.addObserver(self, forKeyPath: "state", options: [], context: &URLSessionTaksOperationKVOContext)
        
        task.resume()
    }
    
    override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        guard context == &URLSessionTaksOperationKVOContext else { return }
        
        stateLock.withCriticalScope {
            if object === task && keyPath == "state" && !observerRemoved {
                switch task.state {
                case .Completed:
                    finish()
                    fallthrough
                case .Canceling:
                    observerRemoved = true
                    task.removeObserver(self, forKeyPath: "state")
                default:
                    return
                }
            }
        }
    }
    
    override public func cancel() {
        task.cancel()
        super.cancel()
    }
}

// The MIT License (MIT)
//
// Copyright (c) 2014 Thomas Visser
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation
import Boilerplate
import ExecutionContext
import CoreFoundation

public func isMainThread() -> Bool {
    return Thread.isMain
}

private class ImmediateOnMainExecutionContextClass : ExecutionContextBase, ExecutionContextType {
    func async(task:SafeTask) {
        if isMainThread() {
            task()
        } else {
            main.async(task)
        }
    }
    
    func async(after:Timeout, task:SafeTask) {
        async {
            Thread.sleep(after)
            task()
        }
    }
    
    func sync<ReturnType>(task:() throws -> ReturnType) rethrows -> ReturnType {
        if isMainThread() {
            return try task()
        } else {
            return try main.sync(task)
        }
    }
    
    func isEqualTo(other:NonStrictEquatable) -> Bool {
        return other is ImmediateOnMainExecutionContextClass
    }
}

/// Immediately executes the given task. No threading, no semaphores.
/// Just for backward compatibility
public let ImmediateExecutionContext: ExecutionContextType = immediate

/// Runs immediately if on the main thread, otherwise asynchronously on the main thread
public let ImmediateOnMainExecutionContext: ExecutionContextType = ImmediateOnMainExecutionContextClass()
public let immediateOnMain: ExecutionContextType = ImmediateOnMainExecutionContext

/// Creates an asynchronous ExecutionContext bound to the given queue
/// Just for backward compatibility
public func toContext(ec: ExecutionContextType) -> ExecutionContextType {
    return ec
}

#if !os(Linux)
/// Creates an asynchronous ExecutionContext bound to the given queue
public func toContext(queue: dispatch_queue_t) -> ExecutionContextType {
    return toContext(DispatchExecutionContext(queue: queue))
}
#endif

typealias ThreadingModel = () -> ExecutionContextType

var DefaultThreadingModel: ThreadingModel = defaultContext

/// Defines BrightFutures' default threading behavior:
/// - if on the main thread, `Queue.main.context` is returned
/// - if off the main thread, `Queue.global.context` is returned
func defaultContext() -> ExecutionContextType {
    return toContext(isMainThread() ? main : global)
}

/// Just for backward compatibility
public struct Queue {
    public static let main = ExecutionContext.main
    public static let global = ExecutionContext.global
}

/// Just for backward compatibility
public extension ExecutionContextType {
    var context:ExecutionContextType {
        get {
            return toContext(self)
        }
    }
}
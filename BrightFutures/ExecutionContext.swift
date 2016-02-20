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
import ExecutionContext
import CoreFoundation

/// The context in which something can be executed
/// By default, an execution context can be assumed to be asynchronous unless stated otherwise
public typealias ExecutionContext = (() -> Void) -> Void

/// Immediately executes the given task. No threading, no semaphores.
public let ImmediateExecutionContext: ExecutionContext = { task in
    task()
}

public func isMainThread() -> Bool {
    return CFRunLoopGetMain() === CFRunLoopGetCurrent()
}

/// Runs immediately if on the main thread, otherwise asynchronously on the main thread
public let ImmediateOnMainExecutionContext: ExecutionContext = { task in
    if isMainThread() {
        task()
    } else {
        main.async(task)
    }
}

/// Creates an asynchronous ExecutionContext bound to the given queue
public func toContext(ec: ExecutionContextType) -> ExecutionContext {
    return ec.async
}

#if !os(Linux)
/// Creates an asynchronous ExecutionContext bound to the given queue
public func toContext(queue: dispatch_queue_t) -> ExecutionContext {
    return toContext(DispatchExecutionContext(queue: queue))
}
#endif

typealias ThreadingModel = () -> ExecutionContext

var DefaultThreadingModel: ThreadingModel = defaultContext

/// Defines BrightFutures' default threading behavior:
/// - if on the main thread, `Queue.main.context` is returned
/// - if off the main thread, `Queue.global.context` is returned
func defaultContext() -> ExecutionContext {
    return toContext(isMainThread() ? main : global)
}

public let globalContext = toContext(global)
public let mainContext = toContext(main)

public extension ExecutionContextType {
    var futureContext:ExecutionContext {
        get {
            return toContext(self)
        }
    }
}
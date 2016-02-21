//
//  NSOperationQueue+BrightFutures.swift
//  BrightFutures
//
//  Created by Thomas Visser on 18/09/15.
//  Copyright © 2015 Thomas Visser. All rights reserved.
//

import Foundation
import ExecutionContext

public extension NSOperationQueue {
    public var context: ExecutionContextType {
        return executionContext { [weak self] task in
            self?.addOperation(NSBlockOperation(block: task))
        }
    }
}
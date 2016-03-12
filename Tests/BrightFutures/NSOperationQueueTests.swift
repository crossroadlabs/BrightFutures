//
//  NSOperationQueueTests.swift
//  BrightFutures
//
//  Created by Thomas Visser on 19/09/15.
//  Copyright © 2015 Thomas Visser. All rights reserved.
//

import XCTest
@testable import BrightFutures
import ExecutionContext
import RunLoop

class NSOperationQueueTests: XCTestCase {

    func testMaxConcurrentOperationCount() {
        let queue = NSOperationQueue()
        queue.maxConcurrentOperationCount = 12
        var i = 0
        
        let sem = BlockingSemaphore(value: 1)
        
        (0...100).forEach { n in
            let e = self.expectation()
            queue.context.execute {
                sem.execute {
                    i++
                }
                XCTAssert(i <= queue.maxConcurrentOperationCount)
                
                sem.execute {
                    i--
                }
                XCTAssert(i >= 0)
                
                e.fulfill()
            }
        }
        
        self.waitForExpectationsWithTimeout(5, handler: nil)
        XCTAssertEqual(i, 0)
    }
    
}

#if os(Linux)
extension NSOperationQueueTests : XCTestCaseProvider {
	var allTests : [(String, () throws -> Void)] {
		return [
			("testMaxConcurrentOperationCount", testMaxConcurrentOperationCount),
		]
	}
}
#endif
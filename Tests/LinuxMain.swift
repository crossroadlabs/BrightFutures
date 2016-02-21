import XCTest

@testable import BrightFuturestest

XCTMain([
	BrightFuturesTests(),
	ErrorsTests(),
	ExecutionContextTests(),
	InvalidationTokenTests(),
	NSOperationQueueTests(),
	PromiseTests(),
	QueueTests(),
	ResultTests(),
	SemaphoreTests(),
])
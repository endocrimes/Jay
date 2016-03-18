import XCTest
@testable import JayTestSuite

XCTMain([
	testCase(ConstsTests.allTests),
	testCase(FormattingTests.allTests),
	testCase(ParsingTests.allTests),
	testCase(ReaderTests.allTests)
	// PerformanceTests(),
])

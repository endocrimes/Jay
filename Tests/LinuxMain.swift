import XCTest
@testable import JayTests

XCTMain([
	testCase(ConstsTests.allTests),
	testCase(FormattingTests.allTests),
	testCase(ParsingTests.allTests),
	testCase(PerformanceTests.allTests),
	testCase(ReaderTests.allTests)
])

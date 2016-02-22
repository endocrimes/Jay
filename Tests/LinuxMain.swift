import XCTest
@testable import Jay
@testable import Jaytest

XCTMain([
	ConstsTests(),
	FormattingTests(),
	ParsingTests(),
	ReaderTests()	
	// PerformanceTests(),
])

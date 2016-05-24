//
//  TestUtils.swift
//  Jay
//
//  Created by Honza Dvorsky on 2/17/16.
//  Copyright © 2016 Honza Dvorsky. All rights reserved.
//

import XCTest
@testable import Jay

func ensureNull(_ val: JSON) {
    XCTAssertEqual(val, JSON.null)
}

func ensureBool(_ val: JSON, exp: Bool, file: StaticString = #file, line: UInt = #line) {
    XCTAssertEqual(val, JSON.boolean(exp))
}

func ensureArray(_ val: JSON, exp: [JSON], file: StaticString = #file, line: UInt = #line) {
    XCTAssertEqual(val, JSON.array(exp))
}

func ensureNumber(_ val: JSON, exp: JSON.Number, file: StaticString = #file, line: UInt = #line) {
    switch val {
    case .number(let num):
        
        switch (num, exp) {
        case (.double(let l), .double(let r)):
            XCTAssertEqualWithAccuracy(r, l, accuracy: 1e-10)
        case (.integer(let l), .integer(let r)):
            XCTAssertEqual(l, r)
        case (.unsignedInteger(let l), .unsignedInteger(let r)):
            XCTAssertEqual(l, r)
        default: XCTFail()
        }
    default: XCTFail()
    }
}

func ensureString(_ val: JSON, exp: String, file: StaticString = #file, line: UInt = #line) {
    XCTAssertEqual(val, JSON.string(exp))
}

func ensureObject(_ val: JSON, exp: [String: JSON], file: StaticString = #file, line: UInt = #line) {
    XCTAssertEqual(val, JSON.object(exp))
}


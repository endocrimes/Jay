//
//  TestUtils.swift
//  Jay
//
//  Created by Honza Dvorsky on 2/17/16.
//  Copyright © 2016 Honza Dvorsky. All rights reserved.
//

import XCTest
@testable import Jay

func ensureNull(_ val: JsonValue) {
    XCTAssertEqual(val, JsonValue.null)
}

func ensureBool(_ val: JsonValue, exp: Bool, file: StaticString = #file, line: UInt = #line) {
    XCTAssertEqual(val, JsonValue.boolean(exp))
}

func ensureArray(_ val: JsonValue, exp: [JsonValue], file: StaticString = #file, line: UInt = #line) {
    XCTAssertEqual(val, JsonValue.array(exp))
}

func ensureNumber(_ val: JsonValue, exp: JsonValue.Number, file: StaticString = #file, line: UInt = #line) {
    switch val {
    case .number(let num):
        
        switch (num, exp) {
        case (.double(let l), .double(let r)):
            XCTAssertEqualWithAccuracy(r, l, accuracy: 1e-10)
        case (.integer(let l), .integer(let r)):
            XCTAssertEqual(l, r)
        default: XCTFail()
        }
    default: XCTFail()
    }
}

func ensureString(_ val: JsonValue, exp: String, file: StaticString = #file, line: UInt = #line) {
    XCTAssertEqual(val, JsonValue.string(exp))
}

func ensureObject(_ val: JsonValue, exp: [String: JsonValue], file: StaticString = #file, line: UInt = #line) {
    XCTAssertEqual(val, JsonValue.object(exp))
}


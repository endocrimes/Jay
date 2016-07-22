//
//  TestUtils.swift
//  Jay
//
//  Created by Honza Dvorsky on 2/17/16.
//  Copyright © 2016 Honza Dvorsky. All rights reserved.
//

import XCTest
@testable import Jay

extension JSON: Equatable { }
public func ==(lhs: JSON, rhs: JSON) -> Bool {
    switch (lhs, rhs) {
    case (.null, .null): return true
    case (.boolean(let l), .boolean(let r)): return l == r
    case (.string(let l), .string(let r)): return l == r
    case (.array(let l), .array(let r)): return l == r
    case (.object(let l), .object(let r)): return l == r
    case (.number(let l), .number(let r)):
        switch (l, r) {
        case (.integer(let ll), .integer(let rr)): return ll == rr
        case (.unsignedInteger(let ll), .unsignedInteger(let rr)): return ll == rr
        case (.double(let ll), .double(let rr)): return ll == rr
        default: return false
        }
    default: return false
    }
}

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


//
//  TestUtils.swift
//  Jay
//
//  Created by Honza Dvorsky on 2/17/16.
//  Copyright © 2016 Honza Dvorsky. All rights reserved.
//

import XCTest

func ensureNull(val: JsonValue) {
    XCTAssertEqual(val, JsonValue.Null)
}

func ensureBool(val: JsonValue, exp: JsonBoolean) {
    XCTAssertEqual(val, JsonValue.Boolean(exp))
}

func ensureArray(val: JsonValue, exp: JsonArray) {
    XCTAssertEqual(val, JsonValue.Array(exp))
}

func ensureNumber(val: JsonValue, exp: JsonNumber) {
    switch val {
    case .Number(let num):
        
        switch (num, exp) {
        case (.JsonDbl(let l), .JsonDbl(let r)):
            XCTAssertEqualWithAccuracy(r, l, accuracy: 1e-10)
        case (.JsonInt(let l), .JsonInt(let r)):
            XCTAssertEqual(l, r)
        default: XCTFail()
        }
    default: XCTFail()
    }
}

func ensureString(val: JsonValue, exp: JsonString) {
    XCTAssertEqual(val, JsonValue.String(exp))
}

func ensureObject(val: JsonValue, exp: JsonObject) {
    XCTAssertEqual(val, JsonValue.Object(exp))
}


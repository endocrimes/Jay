//
//  TestUtils.swift
//  Jay
//
//  Created by Honza Dvorsky on 2/17/16.
//  Copyright © 2016 Honza Dvorsky. All rights reserved.
//

import XCTest
@testable import Jay

func ensureNull(val: ParsedJsonValue) {
    XCTAssertEqual(val, ParsedJsonValue.Null)
}

func ensureBool(val: ParsedJsonValue, exp: JsonBoolean) {
    XCTAssertEqual(val, ParsedJsonValue.Boolean(exp))
}

func ensureArray(val: JsonValue, exp: JsonArray) {
    XCTAssertEqual(val, JsonValue.Array(exp))
}

func ensureArray(val: ParsedJsonValue, exp: JsonArray) {
    XCTAssertEqual(val.stripAnnotations(), JsonValue.Array(exp))
}

func ensureArray(val: ParsedJsonValue, exp: ParsedJsonArray) {
    XCTAssertEqual(val, ParsedJsonValue.Array(exp))
}

func ensureNumber(val: ParsedJsonValue, exp: JsonNumber) {
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

func ensureString(val: ParsedJsonValue, exp: JsonString) {
    XCTAssertEqual(val, ParsedJsonValue.String(exp))
}

func ensureObject(val: ParsedJsonValue, exp: JsonObject) {
    XCTAssertEqual(val.stripAnnotations(), JsonValue.Object(exp))
}

func ensureObject(val: ParsedJsonValue, exp: ParsedJsonObject) {
    XCTAssertEqual(val, ParsedJsonValue.Object(exp))
}


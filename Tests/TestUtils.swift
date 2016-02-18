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
    XCTAssertEqual(val, JsonValue.Number(exp))
}

func ensureString(val: JsonValue, exp: JsonString) {
    XCTAssertEqual(val, JsonValue.String(exp))
}


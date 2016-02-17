//
//  TestUtils.swift
//  Jay
//
//  Created by Honza Dvorsky on 2/17/16.
//  Copyright © 2016 Honza Dvorsky. All rights reserved.
//

import XCTest

func ensureNull(val: JsonValue) {
    switch val {
    case .Null: return
    default: XCTFail()
    }
}

func ensureBool(val: JsonValue, exp: JsonBoolean) {
    switch val {
    case .Boolean(exp): return
    default: XCTFail()
    }
}

func ensureArray(val: JsonValue, exp: JsonArray) {
    switch val {
    case .Array(let exp): return
    default: XCTFail()
    }
}


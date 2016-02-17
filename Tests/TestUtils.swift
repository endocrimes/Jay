//
//  TestUtils.swift
//  Jay
//
//  Created by Honza Dvorsky on 2/17/16.
//  Copyright © 2016 Honza Dvorsky. All rights reserved.
//

import XCTest

func ensureJsonValue(val: Any) -> JsonValue {
    guard let out = val as? JsonValue else { XCTFail(); return JsonValue.Null }
    return out
}

func ensureNull(val: Any) {
    switch ensureJsonValue(val) {
    case .Null: return
    default: XCTFail()
    }
}

func ensureBool(val: Any, exp: JsonBoolean) {
    switch ensureJsonValue(val) {
    case .Boolean(exp): return
    default: XCTFail()
    }
}



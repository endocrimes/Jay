//
//  FormattingTests.swift
//  Jay
//
//  Created by Honza Dvorsky on 2/19/16.
//  Copyright © 2016 Honza Dvorsky. All rights reserved.
//

import XCTest
@testable import Jay

#if os(Linux)
    extension FormattingTests: XCTestCaseProvider {
        var allTests : [(String, () throws -> Void)] {
            return [
                ("testObject_Empty", testObject_Empty),
                ("testNSDictionary_Empty", testNSDictionary_Empty),
                ("testNSDictionary_Simple", testNSDictionary_Simple),
                ("testObject_Simple", testObject_Simple),
                ("testObject_Normal", testObject_Normal),
                ("testObject_Nested", testObject_Nested),
                ("testArray_Empty", testArray_Empty),
                ("testNSArray_Empty", testNSArray_Empty),
                ("testArray_Simple", testArray_Simple),
                ("testArray_Nested", testArray_Nested),
                ("testNSArray_Simple", testNSArray_Simple)
            ]
        }
    }
#endif

class FormattingTests: XCTestCase {

    func testObject_Empty() {
        let json = [String: Int]()
        let data = try! Jay().dataFromJson(json)
        XCTAssertEqual(data, "{}".chars())
    }
    
    func testNSDictionary_Empty() {
        let json = NSDictionary()
        let data = try! Jay().dataFromJson(json)
        XCTAssertEqual(data, "{}".chars())
    }

    func testNSDictionary_Simple() {
        let json = NSDictionary(dictionary: ["hello": "world"])
        let data = try! Jay().dataFromJson(json)
        XCTAssertEqual(data, "{\"hello\":\"world\"}".chars())
    }

    func testObject_Simple() {
        let json = ["hello": "world"]
        let data = try! Jay().dataFromJson(json)
        XCTAssertEqual(data, "{\"hello\":\"world\"}".chars())
    }
    
    func testObject_Normal() {
        let json: [String: Any] = [
            "hello": "world",
            "name": true,
            "many": -12.43
        ]
        let data = try! Jay().dataFromJson(json)
        XCTAssertEqual(data, "{\"hello\":\"world\",\"many\":-12.43,\"name\":true}".chars())
    }

    func testObject_Nested() {
        let json: [String: Any] = [
            "he🇨🇿lo": "wo😎ld",
            "few": [
                true,
                "bad",
                NSNull()
            ] as [Any]
        ]
        let data = try! Jay().dataFromJson(json)
        XCTAssertEqual(data, "{\"few\":[true,\"bad\",null],\"he🇨🇿lo\":\"wo😎ld\"}".chars())
    }

    func testArray_Empty() {
        let json = [Int]()
        let data = try! Jay().dataFromJson(json)
        XCTAssertEqual(data, "[]".chars())
    }
    
    func testNSArray_Empty() {
        let json = NSArray()
        let data = try! Jay().dataFromJson(json)
        XCTAssertEqual(data, "[]".chars())
    }
    
    func testArray_Simple() {
        let json = ["hello", "world"]
        let data = try! Jay().dataFromJson(json)
        XCTAssertEqual(data, "[\"hello\",\"world\"]".chars())
    }
    
    func testArray_Nested() {
        let json: [Any] = [
            "hello",
            -0.34,
            ["guten", true] as [Any],
            "a"
        ]
        let data = try! Jay().dataFromJson(json)
        XCTAssertEqual(data, "[\"hello\",-0.34,[\"guten\",true],\"a\"]".chars())
    }

    func testNSArray_Simple() {
        let json = NSArray(array: ["hello", "world"])
        let data = try! Jay().dataFromJson(json)
        XCTAssertEqual(data, "[\"hello\",\"world\"]".chars())
    }

    
    
}

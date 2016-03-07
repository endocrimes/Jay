//
//  FormattingTests.swift
//  Jay
//
//  Created by Honza Dvorsky on 2/19/16.
//  Copyright © 2016 Honza Dvorsky. All rights reserved.
//

import XCTest
@testable import Jay
import Foundation

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
                       ("testObject_AllTypes", testObject_AllTypes),
                       ("testArray_Empty", testArray_Empty),
                       ("testNSArray_Empty", testNSArray_Empty),
                       ("testArray_Simple", testArray_Simple),
                       ("testArray_Nested", testArray_Nested),
                       ("testNSArray_Simple", testNSArray_Simple),
                       ("testString_Escaping", testString_Escaping),
                       ("testVaporExample_Dict", testVaporExample_Dict),
                       ("testVaporExample_Array", testVaporExample_Array),
                       ("test_Example2", test_Example2)
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
    #if os(Linux)
        let json = ["hello": "world"].bridge()
    #else
        let json = NSDictionary(dictionary: ["hello": "world"])
    #endif
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
    
    func testObject_AllTypes() {
        //testing this works in Jay: https://github.com/Zewo/JSON/pull/4
        let json: [String : Any] = [
            "array double" : [1.2, 2.3, 3.4],
            "array int" : [0, 1, 2, -1],
            "array str" : ["s1", "s2", "s3"],
            "double" : 1.0,
            "int" : 123,
            "string" : "abcde"
        ]
        let data = try! Jay().dataFromJson(json)
        XCTAssertEqual(data, "{\"array double\":[1.2,2.3,3.4],\"array int\":[0,1,2,-1],\"array str\":[\"s1\",\"s2\",\"s3\"],\"double\":1.0,\"int\":123,\"string\":\"abcde\"}".chars())
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
        #if os(Linux)
            let json = ["hello", "world"].bridge()
        #else
            let json = NSArray(array: ["hello", "world"])
        #endif

        let data = try! Jay().dataFromJson(json)
        XCTAssertEqual(data, "[\"hello\",\"world\"]".chars())
    }

    func testString_Escaping() {
        let json = ["he \r\n l \t l \n o w\"o\rrld "]
        let data = try! Jay().dataFromJson(json)
        XCTAssertEqual(data, "[\"he \\r\\n l \\t l \\n o w\\\"o\\rrld \"]".chars())
    }
    
    func testVaporExample_Dict() {
        
        let json = JaySON(
            [
                "number": 123,
                "string": "test",
                "array": [
                    0, 1, 2, 3
                ],
                "dict": [
                    "name": "Vapor",
                    "lang": "Swift"
                ]
            ]
        )
        let data = try! Jay().dataFromJson(json)
        let exp = "{\"array\":[0,1,2,3],\"dict\":{\"lang\":\"Swift\",\"name\":\"Vapor\"},\"number\":123,\"string\":\"test\"}"
        XCTAssertEqual(data, exp.chars(), "Expected: \n\(exp)\ngot\n\(try! data.string())\n")
    }
    
    func testVaporExample_Array() {
        
        let json = JaySON(
            [
                "number",
                123,
                "string",
                "test",
                "array",
                [0, 1, 2, 3],
                "dict",
                [
                    "name": "Vapor",
                    "lang": "Swift"
                ]
            ]
        )
        let data = try! Jay().dataFromJson(json)
        let exp = "[\"number\",123,\"string\",\"test\",\"array\",[0,1,2,3],\"dict\",{\"lang\":\"Swift\",\"name\":\"Vapor\"}]"
        XCTAssertEqual(data, exp.chars(), "Expected: \n\(exp)\ngot\n\(try! data.string())\n")
    }

    //https://twitter.com/schwa/status/706765578631979008
    func test_Example2() {
        let json = JaySON([1,[2,[3]]])
        let data = try! Jay().dataFromJson(json)
        XCTAssertEqual(data, "[1,[2,[3]]]".chars())
    }
    
}

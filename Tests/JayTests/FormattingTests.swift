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

extension FormattingTests {
    static var allTests = [
        ("testObject_Empty", testObject_Empty),
        ("testObject_Empty_Pretty", testObject_Empty_Pretty),
        ("testNSDictionary_Empty", testNSDictionary_Empty),
        ("testNSDictionary_Simple", testNSDictionary_Simple),
        ("testObject_Simple", testObject_Simple),
        ("testObject_Normal", testObject_Normal),
        ("testObject_Nested", testObject_Nested),
        ("testObject_AllTypes", testObject_AllTypes),
        ("testArray_Empty", testArray_Empty),
        ("testArray_Empty_Pretty", testArray_Empty_Pretty),
        ("testNSArray_Empty", testNSArray_Empty),
        ("testArray_Simple", testArray_Simple),
        ("testArray_Nested", testArray_Nested),
        ("testNSArray_Simple", testNSArray_Simple),
        ("testString_Escaping", testString_Escaping),
        ("testVaporExample_Dict", testVaporExample_Dict),
        ("testVaporExample_Array", testVaporExample_Array),
        ("test_Example2", test_Example2),
        ("test_Example3_VeryNested", test_Example3_VeryNested),
        ("test_Example3_VeryNested_Pretty", test_Example3_VeryNested_Pretty)
    ]
}

class FormattingTests: XCTestCase {

    func testObject_Empty() {
        let json = [String: Int]()
        let data = try! Jay().dataFromJson(any: json)
        XCTAssertEqual(data, "{}".chars())
    }
    
    func testNSDictionary_Empty() {
        let json = NSDictionary()
        let data = try! Jay().dataFromJson(any: json)
        XCTAssertEqual(data, "{}".chars())
    }
    
    func testObject_Empty_Pretty() {
        let json = [String: Int]()
        let data = try! Jay(formatting: .prettified).dataFromJson(any: json)
        XCTAssertEqual(data, "{}".chars())
    }
    
    func testNSDictionary_Simple() {
    #if os(Linux)
        let json = ["hello": "world"]._bridgeToObjectiveC()
    #else
        let json = NSDictionary(dictionary: ["hello": "world"])
    #endif
        let data = try! Jay().dataFromJson(any: json)
        XCTAssertEqual(data, "{\"hello\":\"world\"}".chars())
    }

    func testObject_Simple() {
        let json = ["hello": "world"]
        let data = try! Jay().dataFromJson(any: json)
        XCTAssertEqual(data, "{\"hello\":\"world\"}".chars())
    }
    
    func testObject_Normal() {
        let json: JSON = [
            "hello": "world",
            "name": true,
            "many": -12.43
        ]
        let data = try! Jay().dataFromJson(json: json)
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
        let data = try! Jay().dataFromJson(anyDictionary: json)
        XCTAssertEqual(data, "{\"few\":[true,\"bad\",null],\"he🇨🇿lo\":\"wo😎ld\"}".chars())
    }
    
    func testObject_AllTypes() {
        //testing this works in Jay: https://github.com/Zewo/JSON/pull/4
        let json: JSON = [
            "array double": [1.2, 2.3, 3.4],
            "array int" : [0, 1, 2, -1],
            "array str" : ["s1", "s2", "s3"],
            "double" : 1.0,
            "int" : 123,
            "string" : "abcde"
        ]
        let data = try! Jay().dataFromJson(json: json)
        XCTAssertEqual(data, "{\"array double\":[1.2,2.3,3.4],\"array int\":[0,1,2,-1],\"array str\":[\"s1\",\"s2\",\"s3\"],\"double\":1.0,\"int\":123,\"string\":\"abcde\"}".chars())
    }

    func testArray_Empty() {
        let json = [Int]()
        let data = try! Jay().dataFromJson(any: json)
        XCTAssertEqual(data, "[]".chars())
    }
    
    func testArray_Empty_Pretty() {
        let json = [Int]()
        let data = try! Jay(formatting: .prettified).dataFromJson(any: json)
        XCTAssertEqual(data, "[]".chars())
    }
    
    func testNSArray_Empty() {
        let json = NSArray()
        let data = try! Jay().dataFromJson(any: json)
        XCTAssertEqual(data, "[]".chars())
    }
    
    func testArray_Simple() {
        let json = ["hello", "world"]
        let data = try! Jay().dataFromJson(any: json)
        XCTAssertEqual(data, "[\"hello\",\"world\"]".chars())
    }
    
    func testArray_Nested() {
        let json: JSON = [
            "hello",
            -0.34,
            ["guten", true],
            "a"
        ]
        let data = try! Jay().dataFromJson(json: json)
        XCTAssertEqual(data, "[\"hello\",-0.34,[\"guten\",true],\"a\"]".chars())
    }

    func testNSArray_Simple() {
        #if os(Linux)
            let json = ["hello", "world"]._bridgeToObjectiveC()
        #else
            let json = NSArray(array: ["hello", "world"])
        #endif

        let data = try! Jay().dataFromJson(any: json)
        XCTAssertEqual(data, "[\"hello\",\"world\"]".chars())
    }

    func testString_Escaping() {
        let json = ["he \r\n l \t l \n o w\"o\rrld "]
        let data = try! Jay().dataFromJson(any: json)
        XCTAssertEqual(data, "[\"he \\r\\n l \\t l \\n o w\\\"o\\rrld \"]".chars())
    }
    
    func testVaporExample_Dict() {
        
        let json: JSON = [
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
        
        let data = try! Jay().dataFromJson(json: json)
        let exp = "{\"array\":[0,1,2,3],\"dict\":{\"lang\":\"Swift\",\"name\":\"Vapor\"},\"number\":123,\"string\":\"test\"}"
        XCTAssertEqual(data, exp.chars(), "Expected: \n\(exp)\ngot\n\(try! data.string())\n")
    }
    
    func testVaporExample_Array() {
        
        let json: JSON = [
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
        let data = try! Jay().dataFromJson(json: json)
        let exp = "[\"number\",123,\"string\",\"test\",\"array\",[0,1,2,3],\"dict\",{\"lang\":\"Swift\",\"name\":\"Vapor\"}]"
        XCTAssertEqual(data, exp.chars(), "Expected: \n\(exp)\ngot\n\(try! data.string())\n")
    }
    
    //https://twitter.com/schwa/status/706765578631979008
    func test_Example2() {
        //this 'as [Any]' ugliness is here bc on Linux w/out automatic bridging to NSArray, the compiler considers it ambiguous instead of assuming [Any] for some reason. probably reportable as a bug.
        let json: JSON = [1,[2,[3]]]
        let data = try! Jay().dataFromJson(json: json)
        XCTAssertEqual(data, "[1,[2,[3]]]".chars())
    }
    
    func test_Example3_VeryNested() {
        let json: JSON = [
            "number",
            123,
            "string",
            "test",
            "array",
            [0, 1, 2, 3],
            "dict",
            [
                "name": "Vapor",
                "lang": [
                    "new": 1,
                    "name": ["swift", 5]
                ]
            ]
        ]
        let data = try! Jay().dataFromJson(json: json)
        let exp = "[\"number\",123,\"string\",\"test\",\"array\",[0,1,2,3],\"dict\",{\"lang\":{\"name\":[\"swift\",5],\"new\":1},\"name\":\"Vapor\"}]"
        XCTAssertEqual(data, exp.chars(), "Expected: \n\(exp)\ngot\n\(try! data.string())\n")
    }
    
    func test_Example3_VeryNested_Pretty() {
        let json: JSON = [
            "number",
            123,
            "string",
            "test",
            "array",
            [0, 1, 2, 3],
            "dict",
            [
                "name": "Vapor",
                "lang": [
                    "new": 1,
                    "name": ["swift", 5]
                ]
            ]
        ]
        
        let data = try! Jay(formatting: .prettified).dataFromJson(json: json)
        let exp = "[\n    \"number\",\n    123,\n    \"string\",\n    \"test\",\n    \"array\",\n    [\n        0,\n        1,\n        2,\n        3\n    ],\n    \"dict\",\n    {\n        \"lang\": {\n            \"name\": [\n                \"swift\",\n                5\n            ],\n            \"new\": 1\n        },\n        \"name\": \"Vapor\"\n    }\n]"
        XCTAssertEqual(data, exp.chars(), "Expected: \n\(exp)\ngot\n\(try! data.string())\n")
    }
}

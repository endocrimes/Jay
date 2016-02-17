//
//  ParsingTests.swift
//  Jay
//
//  Created by Honza Dvorsky on 2/17/16.
//  Copyright © 2016 Honza Dvorsky. All rights reserved.
//

import XCTest

class ParsingTests: XCTestCase {

//    func testParsing_Example1() {
//        
//        XCTFail()
////        let data = "{\t\"hello\" : \"world\", \n\t \"val\": 1234}".cchars()
////        let obj = try! Parser().parseJsonFromData(data)
////        print("\(obj)")
////        print("\(obj)")
////        XCTAssertEqual(obj as! [String: Any], ["hello":"world","val":1234] as [String: Any])
//    }
    
    func testPrepareForReading_FailOnEmpty() {
        let reader = ByteReader(content: "")
        let ret = try? NullParser().prepareForReading(withReader: reader)
        XCTAssertNil(ret)
    }
    
    func testNull_Normal() {
        
        let reader = ByteReader(content: "null,   heyo")
        let ret = try! NullParser().parse(withReader: reader)
        ensureNull(ret.0)
        XCTAssert(ret.1.curr() == ",".cchar())
    }
    
    func testNull_Mismatch() {
        
        let reader = ByteReader(content: "NAll")
        let ret = try? NullParser().parse(withReader: reader)
        XCTAssertNil(ret)
    }
    
    func testBoolean_True_Normal() {
        
        let reader = ByteReader(content: "true, ")
        let ret = try! BooleanParser().parse(withReader: reader)
        ensureBool(ret.0, exp: JsonBoolean.True)
        XCTAssert(ret.1.curr() == ",".cchar())
    }

    func testBoolean_True_Mismatch() {
        
        let reader = ByteReader(content: "tRue, ")
        let ret = try? BooleanParser().parse(withReader: reader)
        XCTAssertNil(ret)
    }

    func testBoolean_False_Normal() {
        
        let reader = ByteReader(content: "false, ")
        let ret = try! BooleanParser().parse(withReader: reader)
        ensureBool(ret.0, exp: JsonBoolean.False)
        XCTAssert(ret.1.curr() == ",".cchar())
    }
    
    func testBoolean_False_Mismatch() {
        
        let reader = ByteReader(content: "fals, ")
        let ret = try? BooleanParser().parse(withReader: reader)
        XCTAssertNil(ret)
    }

    func testArray_NullsAndBooleans_Normal_Minimal_RootParser() {
        
        let reader = ByteReader(content: "[null,true,false]")
        let ret = try! RootParser().parse(withReader: reader)
        let exp: JsonArray = [
            JsonValue.Null,
            JsonValue.Boolean(JsonBoolean.True),
            JsonValue.Boolean(JsonBoolean.False)
        ]
        ensureArray(ret.0, exp: exp)
        XCTAssert(ret.1.isDone())
    }

    func testArray_NullsAndBooleans_Normal_MuchWhitespace() {
        
        let reader = ByteReader(content: " \t[\n  null ,true, \nfalse\r\n]\n  ")
        let ret = try! ArrayParser().parse(withReader: reader)
        let exp: JsonArray = [
            JsonValue.Null,
            JsonValue.Boolean(JsonBoolean.True),
            JsonValue.Boolean(JsonBoolean.False)
        ]
        ensureArray(ret.0, exp: exp)
        XCTAssert(ret.1.curr() == "\n".cchar())
    }
    
    func testArray_NullsAndBooleans_Bad_MissingEnd() {
        
        let reader = ByteReader(content: " \t[\n  null ,true, \nfalse\r\n\n  ")
        let ret = try? ArrayParser().parse(withReader: reader)
        XCTAssertNil(ret)
    }
    
    func testArray_NullsAndBooleans_Bad_MissingComma() {
        
        let reader = ByteReader(content: " \t[\n  null true, \nfalse\r\n]\n  ")
        let ret = try? ArrayParser().parse(withReader: reader)
        XCTAssertNil(ret)
    }
    
    func testArray_NullsAndBooleans_Bad_ExtraComma() {
        
        let reader = ByteReader(content: " \t[\n  null , , true, \nfalse\r\n]\n  ")
        let ret = try? ArrayParser().parse(withReader: reader)
        XCTAssertNil(ret)
    }

    func testArray_NullsAndBooleans_Bad_TrailingComma() {
        
        let reader = ByteReader(content: " \t[\n  null ,true, \nfalse\r\n, ]\n  ")
        let ret = try? ArrayParser().parse(withReader: reader)
        XCTAssertNil(ret)
    }

    func testNumber_Int_Basic() {
        let reader = ByteReader(content: "24")
        let ret = try! NumberParser().parse(withReader: reader)
        ensureNumber(ret.0, exp: JsonNumber.JsonInt(24))
    }
    
    func testNumber_Int_Negative() {
        let reader = ByteReader(content: "24")
        let ret = try! NumberParser().parse(withReader: reader)
        ensureNumber(ret.0, exp: JsonNumber.JsonInt(24))
    }
    
    func testNumber_Dbl_Basic() {
        let reader = ByteReader(content: "24.34")
        let ret = try! NumberParser().parse(withReader: reader)
        ensureNumber(ret.0, exp: JsonNumber.JsonDbl(24.34))
    }
    
    func testNumber_Dbl_Negative() {
        let reader = ByteReader(content: "-24.34")
        let ret = try! NumberParser().parse(withReader: reader)
        ensureNumber(ret.0, exp: JsonNumber.JsonDbl(-24.34))
    }


    
}

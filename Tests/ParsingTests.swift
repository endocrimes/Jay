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
        let ret = try? Parser().prepareForReading(withReader: reader)
        XCTAssertNil(ret)
    }
    
    func testNull_Normal() {
        
        let reader = ByteReader(content: "null,   heyo")
        let ret = try! Parser().parseNull(withReader: reader)
        ensureNull(ret.0)
        XCTAssert(ret.1.curr() == ",".cchar())
    }
    
    func testNull_Mismatch() {
        
        let reader = ByteReader(content: "NAll")
        let ret = try? Parser().parseNull(withReader: reader)
        XCTAssertNil(ret)
    }
    
    func testBoolean_True_Normal() {
        
        let reader = ByteReader(content: "true, ")
        let ret = try! Parser().parseBoolean(withReader: reader)
        ensureBool(ret.0, exp: JsonBoolean.True)
        XCTAssert(ret.1.curr() == ",".cchar())
    }

    func testBoolean_True_Mismatch() {
        
        let reader = ByteReader(content: "tRue, ")
        let ret = try? Parser().parseBoolean(withReader: reader)
        XCTAssertNil(ret)
    }

    func testBoolean_False_Normal() {
        
        let reader = ByteReader(content: "false, ")
        let ret = try! Parser().parseBoolean(withReader: reader)
        ensureBool(ret.0, exp: JsonBoolean.False)
        XCTAssert(ret.1.curr() == ",".cchar())
    }
    
    func testBoolean_False_Mismatch() {
        
        let reader = ByteReader(content: "fals, ")
        let ret = try? Parser().parseBoolean(withReader: reader)
        XCTAssertNil(ret)
    }


    
}

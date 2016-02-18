//
//  ConstsTests.swift
//  Jay
//
//  Created by Honza Dvorsky on 2/17/16.
//  Copyright © 2016 Honza Dvorsky. All rights reserved.
//

import XCTest

class ConstsTests: XCTestCase {

    func testConsts() {
        XCTAssertEqual(try! Const.BeginArray.string(), "[")
        XCTAssertEqual(try! Const.BeginObject.string(), "{")
        XCTAssertEqual(try! Const.EndArray.string(), "]")
        XCTAssertEqual(try! Const.EndObject.string(), "}")
        XCTAssertEqual(try! Const.NameSeparator.string(), ":")
        XCTAssertEqual(try! Const.ValueSeparator.string(), ",")
        
        XCTAssertEqual(try! Const.Space.string(), " ")
        XCTAssertEqual(try! Const.HorizontalTab.string(), "\t")
        XCTAssertEqual(try! Const.NewLine.string(), "\n")
        XCTAssertEqual(try! Const.CarriageReturn.string(), "\r")
        
        XCTAssertEqual(try! Const.False.string(), "false")
        XCTAssertEqual(try! Const.Null.string(), "null")
        XCTAssertEqual(try! Const.True.string(), "true")
    }
    
    func testUnicodeTesting() {
        XCTAssert(StringParser().isValidUnicodeHexDigit("uab01".chars()) == true)
        XCTAssert(StringParser().isValidUnicodeHexDigit("uAB01".chars()) == true)
        XCTAssert(StringParser().isValidUnicodeHexDigit("uaB09".chars()) == true)
        XCTAssert(StringParser().isValidUnicodeHexDigit("u0000".chars()) == true)
        XCTAssert(StringParser().isValidUnicodeHexDigit("uFFFF".chars()) == true)
        
        XCTAssert(StringParser().isValidUnicodeHexDigit("FFFF".chars()) == false)
        XCTAssert(StringParser().isValidUnicodeHexDigit("ug001".chars()) == false)
        XCTAssert(StringParser().isValidUnicodeHexDigit("u12345".chars()) == false)
        XCTAssert(StringParser().isValidUnicodeHexDigit("u12F".chars()) == false)
    }
        
}

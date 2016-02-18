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

    func testArray_NullsBoolsNums_Normal_Minimal_RootParser() {
        
        let reader = ByteReader(content: "[null,true,false,12,-24.3,18.2e9]")
        let ret = try! RootParser().parse(withReader: reader)
        let exp: JsonArray = [
            JsonValue.Null,
            JsonValue.Boolean(JsonBoolean.True),
            JsonValue.Boolean(JsonBoolean.False),
            JsonValue.Number(JsonNumber.JsonInt(12)),
            JsonValue.Number(JsonNumber.JsonDbl(-24.3)),
            JsonValue.Number(JsonNumber.JsonDbl(18200000000)),
        ]
        ensureArray(ret.0, exp: exp)
        XCTAssert(ret.1.isDone())
    }

    func testArray_NullsBoolsNums_Normal_MuchWhitespace() {
        
        let reader = ByteReader(content: " \t[\n  null ,true, \n-12.3 , false\r\n]\n  ")
        let ret = try! ArrayParser().parse(withReader: reader)
        let exp: JsonArray = [
            JsonValue.Null,
            JsonValue.Boolean(JsonBoolean.True),
            JsonValue.Number(JsonNumber.JsonDbl(-12.3)),
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
        let reader = ByteReader(content: "24  ")
        let ret = try! NumberParser().parse(withReader: reader)
        ensureNumber(ret.0, exp: JsonNumber.JsonInt(24))
    }
    
    func testNumber_Int_Negative() {
        let reader = ByteReader(content: "24 , ")
        let ret = try! NumberParser().parse(withReader: reader)
        ensureNumber(ret.0, exp: JsonNumber.JsonInt(24))
    }
    
    func testNumber_Dbl_Basic() {
        let reader = ByteReader(content: "24.34, ")
        let ret = try! NumberParser().parse(withReader: reader)
        ensureNumber(ret.0, exp: JsonNumber.JsonDbl(24.34))
    }
    
    func testNumber_Dbl_Incomplete() {
        let reader = ByteReader(content: "24., ")
        let ret = try? NumberParser().parse(withReader: reader)
        XCTAssertNil(ret)
    }
    
    func testNumber_Dbl_Negative() {
        let reader = ByteReader(content: "-24.34]")
        let ret = try! NumberParser().parse(withReader: reader)
        ensureNumber(ret.0, exp: JsonNumber.JsonDbl(-24.34))
    }
    
    func testNumber_Dbl_Negative_WrongChar() {
        let reader = ByteReader(content: "-24.3a4]")
        let ret = try? NumberParser().parse(withReader: reader)
        XCTAssertNil(ret)
    }

    func testNumber_Dbl_Negative_TwoDecimalPoints() {
        let reader = ByteReader(content: "-24.3.4]")
        let ret = try? NumberParser().parse(withReader: reader)
        XCTAssertNil(ret)
    }
    
    func testNumber_Dbl_Negative_TwoMinuses() {
        let reader = ByteReader(content: "--24.34]")
        let ret = try? NumberParser().parse(withReader: reader)
        XCTAssertNil(ret)
    }

    func testNumber_Double_Exp_Normal() {
        let reader = ByteReader(content: "-24.3245e2, ")
        let ret = try! NumberParser().parse(withReader: reader)
        ensureNumber(ret.0, exp: JsonNumber.JsonDbl(-2432.45))
    }
    
    func testNumber_Double_Exp_NoFrac() {
        let reader = ByteReader(content: "24E2, ")
        let ret = try! NumberParser().parse(withReader: reader)
        ensureNumber(ret.0, exp: JsonNumber.JsonDbl(2400))
    }

    func testNumber_Double_Exp_TwoEs() {
        let reader = ByteReader(content: "-24.3245eE2, ")
        let ret = try? NumberParser().parse(withReader: reader)
        XCTAssertNil(ret)
    }

    func testEscape_Unicode_Normal() {
        
        var reader: Reader = ByteReader(content: "\\u0048 ")
        let char: Character
        (char, reader) = try! StringParser().unescapedCharacter(reader)
        
        XCTAssert(String(char) == "H")
    }
    
    func testEscape_Unicode_InvalidUnicode_MissingDigit() {
        
        let reader: Reader = ByteReader(content: "\\u048 ")
        XCTAssertNil(try? StringParser().unescapedCharacter(reader))
    }
    
    func testEscape_Unicode_InvalidUnicode_MissingAllDigits() {
        
        let reader: Reader = ByteReader(content: "\\u ")
        XCTAssertNil(try? StringParser().unescapedCharacter(reader))
    }

    func testEscape_SpecialChars() {
        
        let chars: [CChar] = [
            Const.Escape, Const.QuotationMark,
            Const.Escape, Const.ReverseSolidus,
            Const.Escape, Const.Solidus,
            Const.Escape, Const.Backspace,
            Const.Escape, Const.FormFeed,
            Const.Escape, Const.NewLine,
            Const.Escape, Const.CarriageReturn,
            Const.Escape, Const.HorizontalTab,
            Const.Space
        ]
        
        var reader: Reader = ByteReader(content: chars)
        var char: Character
        
        (char, reader) = try! StringParser().unescapedCharacter(reader)
        XCTAssert("\"" == String(char))

        (char, reader) = try! StringParser().unescapedCharacter(reader)
        XCTAssert("\\" == String(char))

        (char, reader) = try! StringParser().unescapedCharacter(reader)
        XCTAssert("/" == String(char))

        (char, reader) = try! StringParser().unescapedCharacter(reader)
        XCTAssert(try! Const.Backspace.string() == String(char))

        (char, reader) = try! StringParser().unescapedCharacter(reader)
        XCTAssert(try! Const.FormFeed.string() == String(char))

        (char, reader) = try! StringParser().unescapedCharacter(reader)
        XCTAssert("\n" == String(char))

        (char, reader) = try! StringParser().unescapedCharacter(reader)
        XCTAssert("\r" == String(char))

        (char, reader) = try! StringParser().unescapedCharacter(reader)
        XCTAssert("\t" == String(char))
    }

    
    //TODO test string: emoji, normal alphabet, regular unicode

}

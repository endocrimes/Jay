//
//  ParsingTests.swift
//  Jay
//
//  Created by Honza Dvorsky on 2/17/16.
//  Copyright © 2016 Honza Dvorsky. All rights reserved.
//

import XCTest
@testable import Jay
import Foundation

#if os(Linux)
    extension ParsingTests {
        static var allTests : [(String, (ParsingTests) -> () throws -> Void)] {
            return [
                       ("testPrepareForReading_FailOnEmpty", testPrepareForReading_FailOnEmpty),
                       ("testExtraTokensThrow", testExtraTokensThrow),
                       ("testNull_Normal", testNull_Normal),
                       ("testNull_Mismatch", testNull_Mismatch),
                       ("testBoolean_True_Normal", testBoolean_True_Normal),
                       ("testBoolean_True_Mismatch", testBoolean_True_Mismatch),
                       ("testBoolean_False_Normal", testBoolean_False_Normal),
                       ("testBoolean_False_Mismatch", testBoolean_False_Mismatch),
                       ("testArray_NullsBoolsNums_Normal_Minimal_RootParser", testArray_NullsBoolsNums_Normal_Minimal_RootParser),
                       ("testArray_NullsBoolsNums_Normal_MuchWhitespace", testArray_NullsBoolsNums_Normal_MuchWhitespace),
                       ("testArray_NullsAndBooleans_Bad_MissingEnd", testArray_NullsAndBooleans_Bad_MissingEnd),
                       ("testArray_NullsAndBooleans_Bad_MissingComma", testArray_NullsAndBooleans_Bad_MissingComma),
                       ("testArray_NullsAndBooleans_Bad_ExtraComma", testArray_NullsAndBooleans_Bad_ExtraComma),
                       ("testArray_NullsAndBooleans_Bad_TrailingComma", testArray_NullsAndBooleans_Bad_TrailingComma),
                       ("testNumber_Int_Zero", testNumber_Int_Zero),
                       ("testNumber_Int_One", testNumber_Int_One),
                       ("testNumber_Int_Basic", testNumber_Int_Basic),
                       ("testNumber_Int_Negative", testNumber_Int_Negative),
                       ("testNumber_Dbl_Basic", testNumber_Dbl_Basic),
                       ("testNumber_Dbl_ZeroSomething", testNumber_Dbl_ZeroSomething),
                       ("testNumber_Dbl_MinusZeroSomething", testNumber_Dbl_MinusZeroSomething),
                       ("testNumber_Dbl_Incomplete", testNumber_Dbl_Incomplete),
                       ("testNumber_Dbl_Negative", testNumber_Dbl_Negative),
                       ("testNumber_Dbl_Negative_WrongChar", testNumber_Dbl_Negative_WrongChar),
                       ("testNumber_Dbl_Negative_TwoDecimalPoints", testNumber_Dbl_Negative_TwoDecimalPoints),
                       ("testNumber_Dbl_Negative_TwoMinuses", testNumber_Dbl_Negative_TwoMinuses),
                       ("testNumber_Double_Exp_Normal", testNumber_Double_Exp_Normal),
                       ("testNumber_Double_Exp_Positive", testNumber_Double_Exp_Positive),
                       ("testNumber_Double_Exp_Negative", testNumber_Double_Exp_Negative),
                       ("testNumber_Double_Exp_NoFrac", testNumber_Double_Exp_NoFrac),
                       ("testNumber_Double_Exp_TwoEs", testNumber_Double_Exp_TwoEs),
                       ("testEscape_Unicode_Normal", testEscape_Unicode_Normal),
                       ("testEscape_Unicode_InvalidUnicode_MissingDigit", testEscape_Unicode_InvalidUnicode_MissingDigit),
                       ("testEscape_Unicode_InvalidUnicode_MissingAllDigits", testEscape_Unicode_InvalidUnicode_MissingAllDigits),
                       ("testEscape_SpecialChars", testEscape_SpecialChars),
                       ("testString_Empty", testString_Empty),
                       ("testString_Normal", testString_Normal),
                       ("testString_Normal_WhitespaceInside", testString_Normal_WhitespaceInside),
                       ("testString_StartEndWithSpaces", testString_StartEndWithSpaces),
                       ("testString_Unicode_RegularChar", testString_Unicode_RegularChar),
                       ("testString_Unicode_SpecialCharacter_CoolA", testString_Unicode_SpecialCharacter_CoolA),
                       ("testString_Unicode_SpecialCharacter_HebrewShin", testString_Unicode_SpecialCharacter_HebrewShin),
                       ("testString_Unicode_SpecialCharacter_QuarterTo", testString_Unicode_SpecialCharacter_QuarterTo),
                       ("testString_Unicode_SpecialCharacter_EmojiSimple", testString_Unicode_SpecialCharacter_EmojiSimple),
                       ("testString_Unicode_SpecialCharacter_EmojiComplex", testString_Unicode_SpecialCharacter_EmojiComplex),
                       ("testString_SpecialCharacter_QuarterTo", testString_SpecialCharacter_QuarterTo),
                       ("testString_SpecialCharacter_EmojiSimple", testString_SpecialCharacter_EmojiSimple),
                       ("testString_SpecialCharacter_EmojiComplex", testString_SpecialCharacter_EmojiComplex),
                       ("testObject_Empty", testObject_Empty),
                       ("testObject_Example1", testObject_Example1),
                       ("testObject_DirectReader_Example1", testObject_DirectReader_Example1),
                       ("testNative_Example1", testNative_Example1),
                       ("test_Example2", test_Example2)
            ]
        }
    }
#endif

class ParsingTests:XCTestCase {
    
    func testPrepareForReading_FailOnEmpty() {
        let reader = ByteReader(content: "")
        let ret = try? ValueParser().prepareForReading(withReader: reader)
        XCTAssertNil(ret)
    }
    
    func testExtraTokensThrow() {
        let data = "{\"hello\":\"world\"} blah".chars()
        let ret = try? Parser().parseJsonFromData(data)
        XCTAssertNil(ret)
    }
    
    func testNull_Normal() {
        
        let reader = ByteReader(content: "null,   heyo")
        let ret = try! ValueParser().parse(withReader: reader)
        ensureNull(ret.0)
        XCTAssert(ret.1.curr() == ",".char())
    }
    
    func testNull_Mismatch() {
        
        let reader = ByteReader(content: "NAll")
        let ret = try? ValueParser().parse(withReader: reader)
        XCTAssertNil(ret)
    }
    
    func testBoolean_True_Normal() {
        
        let reader = ByteReader(content: "true, ")
        let ret = try! ValueParser().parse(withReader: reader)
        ensureBool(ret.0, exp: JsonBoolean.True)
        XCTAssert(ret.1.curr() == ",".char())
    }

    func testBoolean_True_Mismatch() {
        
        let reader = ByteReader(content: "tRue, ")
        let ret = try? ValueParser().parse(withReader: reader)
        XCTAssertNil(ret)
    }

    func testBoolean_False_Normal() {
        
        let reader = ByteReader(content: "false, ")
        let ret = try! ValueParser().parse(withReader: reader)
        ensureBool(ret.0, exp: JsonBoolean.False)
        XCTAssert(ret.1.curr() == ",".char())
    }
    
    func testBoolean_False_Mismatch() {
        
        let reader = ByteReader(content: "fals, ")
        let ret = try? ValueParser().parse(withReader: reader)
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
        let ret = try! ValueParser().parse(withReader: reader)
        let exp: JsonArray = [
            JsonValue.Null,
            JsonValue.Boolean(JsonBoolean.True),
            JsonValue.Number(JsonNumber.JsonDbl(-12.3)),
            JsonValue.Boolean(JsonBoolean.False)
        ]
        ensureArray(ret.0, exp: exp)
        XCTAssert(ret.1.curr() == "\n".char())
    }
    
    func testArray_NullsAndBooleans_Bad_MissingEnd() {
        
        let reader = ByteReader(content: " \t[\n  null ,true, \nfalse\r\n\n  ")
        let ret = try? ValueParser().parse(withReader: reader)
        XCTAssertNil(ret)
    }
    
    func testArray_NullsAndBooleans_Bad_MissingComma() {
        
        let reader = ByteReader(content: " \t[\n  null true, \nfalse\r\n]\n  ")
        let ret = try? ValueParser().parse(withReader: reader)
        XCTAssertNil(ret)
    }
    
    func testArray_NullsAndBooleans_Bad_ExtraComma() {
        
        let reader = ByteReader(content: " \t[\n  null , , true, \nfalse\r\n]\n  ")
        let ret = try? ValueParser().parse(withReader: reader)
        XCTAssertNil(ret)
    }

    func testArray_NullsAndBooleans_Bad_TrailingComma() {
        
        let reader = ByteReader(content: " \t[\n  null ,true, \nfalse\r\n, ]\n  ")
        let ret = try? ValueParser().parse(withReader: reader)
        XCTAssertNil(ret)
    }

    func testNumber_Int_Zero() {
        let reader = ByteReader(content: "0  ")
        let ret = try! ValueParser().parse(withReader: reader)
        ensureNumber(ret.0, exp: JsonNumber.JsonInt(0))
    }
    
    func testNumber_Int_One() {
        let reader = ByteReader(content: "1  ")
        let ret = try! ValueParser().parse(withReader: reader)
        ensureNumber(ret.0, exp: JsonNumber.JsonInt(1))
    }

    func testNumber_Int_Basic() {
        let reader = ByteReader(content: "24  ")
        let ret = try! ValueParser().parse(withReader: reader)
        ensureNumber(ret.0, exp: JsonNumber.JsonInt(24))
    }
    
    func testNumber_Int_Negative() {
        let reader = ByteReader(content: "24 , ")
        let ret = try! ValueParser().parse(withReader: reader)
        ensureNumber(ret.0, exp: JsonNumber.JsonInt(24))
    }
    
    func testNumber_Dbl_Basic() {
        let reader = ByteReader(content: "24.34, ")
        let ret = try! ValueParser().parse(withReader: reader)
        ensureNumber(ret.0, exp: JsonNumber.JsonDbl(24.34))
    }
    
    func testNumber_Dbl_ZeroSomething() {
        let reader = ByteReader(content: "0.34, ")
        let ret = try! ValueParser().parse(withReader: reader)
        ensureNumber(ret.0, exp: JsonNumber.JsonDbl(0.34))
    }
    
    func testNumber_Dbl_MinusZeroSomething() {
        let reader = ByteReader(content: "-0.34, ")
        let ret = try! ValueParser().parse(withReader: reader)
        ensureNumber(ret.0, exp: JsonNumber.JsonDbl(-0.34))
    }
    
    func testNumber_Dbl_Incomplete() {
        let reader = ByteReader(content: "24., ")
        let ret = try? ValueParser().parse(withReader: reader)
        XCTAssertNil(ret)
    }
    
    func testNumber_Dbl_Negative() {
        let reader = ByteReader(content: "-24.34]")
        let ret = try! ValueParser().parse(withReader: reader)
        ensureNumber(ret.0, exp: JsonNumber.JsonDbl(-24.34))
    }
    
    func testNumber_Dbl_Negative_WrongChar() {
        let reader = ByteReader(content: "-24.3a4]")
        let ret = try? ValueParser().parse(withReader: reader)
        XCTAssertNil(ret)
    }

    func testNumber_Dbl_Negative_TwoDecimalPoints() {
        let reader = ByteReader(content: "-24.3.4]")
        let ret = try? ValueParser().parse(withReader: reader)
        XCTAssertNil(ret)
    }
    
    func testNumber_Dbl_Negative_TwoMinuses() {
        let reader = ByteReader(content: "--24.34]")
        let ret = try? ValueParser().parse(withReader: reader)
        XCTAssertNil(ret)
    }

    func testNumber_Double_Exp_Normal() {
        let reader = ByteReader(content: "-24.3245e2, ")
        let ret = try! ValueParser().parse(withReader: reader)
        ensureNumber(ret.0, exp: JsonNumber.JsonDbl(-2432.45))
    }
    
    func testNumber_Double_Exp_Positive() {
        let reader = ByteReader(content: "-24.3245e+2, ")
        let ret = try! ValueParser().parse(withReader: reader)
        ensureNumber(ret.0, exp: JsonNumber.JsonDbl(-2432.45))
    }
    
    func testNumber_Double_Exp_Negative() {
        let reader = ByteReader(content: "-24.3245e-2, ")
        let ret = try! ValueParser().parse(withReader: reader)
        ensureNumber(ret.0, exp: JsonNumber.JsonDbl(-0.243245))
    }
    
    func testNumber_Double_Exp_NoFrac() {
        let reader = ByteReader(content: "24E2, ")
        let ret = try! ValueParser().parse(withReader: reader)
        ensureNumber(ret.0, exp: JsonNumber.JsonDbl(2400))
    }

    func testNumber_Double_Exp_TwoEs() {
        let reader = ByteReader(content: "-24.3245eE2, ")
        let ret = try? ValueParser().parse(withReader: reader)
        XCTAssertNil(ret)
    }

    func testEscape_Unicode_Normal() {
        
        var reader: Reader = ByteReader(content: "\\u0048 ")
        let char: UnicodeScalar
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
        
        let chars: [JChar] = [
            //regular translation
            Const.Escape, Const.QuotationMark,
            Const.Escape, Const.ReverseSolidus,
            Const.Escape, Const.Solidus,
            
            //special substitution
            Const.Escape, Const.BackspaceChar,
            Const.Escape, Const.FormFeedChar,
            Const.Escape, Const.NewLineChar,
            Const.Escape, Const.CarriageReturnChar,
            Const.Escape, Const.HorizontalTabChar,
            Const.Space
        ]
        
        var reader: Reader = ByteReader(content: chars)
        var char: UnicodeScalar
        
        //regular
        
        (char, reader) = try! StringParser().unescapedCharacter(reader)
        XCTAssert(try! Const.QuotationMark.string() == String(char))

        (char, reader) = try! StringParser().unescapedCharacter(reader)
        XCTAssert(try! Const.ReverseSolidus.string() == String(char))

        (char, reader) = try! StringParser().unescapedCharacter(reader)
        XCTAssert(try! Const.Solidus.string() == String(char))

        
        //rule-based
        
        (char, reader) = try! StringParser().unescapedCharacter(reader)
        XCTAssert(try! Const.Backspace.string() == String(char))

        (char, reader) = try! StringParser().unescapedCharacter(reader)
        XCTAssert(try! Const.FormFeed.string() == String(char))

        (char, reader) = try! StringParser().unescapedCharacter(reader)
        XCTAssertEqual(try! Const.NewLine.string(), String(char))

        (char, reader) = try! StringParser().unescapedCharacter(reader)
        XCTAssertEqual(try! Const.CarriageReturn.string(), String(char))

        (char, reader) = try! StringParser().unescapedCharacter(reader)
        XCTAssertEqual(try! Const.HorizontalTab.string(), String(char))
    }
    
    func testString_Empty() {
        let reader = ByteReader(content: "\"\" ")
        let ret = try! ValueParser().parse(withReader: reader)
        ensureString(ret.0, exp: "")
    }
    
    func testString_Normal() {
        let reader = ByteReader(content: "\"hello world\" ")
        let ret = try! ValueParser().parse(withReader: reader)
        ensureString(ret.0, exp: "hello world")
    }
    
    func testString_Normal_WhitespaceInside() {
        let reader = ByteReader(content: "\"he \\r\\n l \\t l \\n o wo\\rrld \" ")
        let ret = try! ValueParser().parse(withReader: reader)
        ensureString(ret.0, exp: "he \r\n l \t l \n o wo\rrld ")
    }
    
    func testString_StartEndWithSpaces() {
        let reader = ByteReader(content: "\"  hello world    \" ")
        let ret = try! ValueParser().parse(withReader: reader)
        ensureString(ret.0, exp: "  hello world    ")
    }
    
    func testString_Unicode_RegularChar() {
        let reader = ByteReader(content: "\"hel\\u006co world\" ")
        let ret = try! ValueParser().parse(withReader: reader)
        ensureString(ret.0, exp: "hello world")
    }
    
    func testString_Unicode_SpecialCharacter_CoolA() {
        let reader = ByteReader(content: "\"h\\u01cdw\" ")
        let ret = try! ValueParser().parse(withReader: reader)
        ensureString(ret.0, exp: "hǍw")
    }

    func testString_Unicode_SpecialCharacter_HebrewShin() {
        let reader = ByteReader(content: "\"h\\u05e9w\" ")
        let ret = try! ValueParser().parse(withReader: reader)
        ensureString(ret.0, exp: "hשw")
    }
    
    func testString_Unicode_SpecialCharacter_QuarterTo() {
        let reader = ByteReader(content: "\"h\\u25d5w\" ")
        let ret = try! ValueParser().parse(withReader: reader)
        ensureString(ret.0, exp: "h◕w")
    }
    
    func testString_Unicode_SpecialCharacter_EmojiSimple() {
        let reader = ByteReader(content: "\"h\\ud83d\\ude3bw\" ")
        let ret = try! ValueParser().parse(withReader: reader)
        ensureString(ret.0, exp: "h😻w")
    }
    
    func testString_Unicode_SpecialCharacter_EmojiComplex() {
        let reader = ByteReader(content: "\"h\\ud83c\\udde8\\ud83c\\uddffw\" ")
        let ret = try! ValueParser().parse(withReader: reader)
        ensureString(ret.0, exp: "h🇨🇿w")
    }
    
    func testString_SpecialCharacter_QuarterTo() {
        let reader = ByteReader(content: "\"h◕w\" ")
        let ret = try! ValueParser().parse(withReader: reader)
        ensureString(ret.0, exp: "h◕w")
    }

    func testString_SpecialCharacter_EmojiSimple() {
        let reader = ByteReader(content: "\"h😻w\" ")
        let ret = try! ValueParser().parse(withReader: reader)
        ensureString(ret.0, exp: "h😻w")
    }

    func testString_SpecialCharacter_EmojiComplex() {
        let reader = ByteReader(content: "\"h🇨🇿w\" ")
        let ret = try! ValueParser().parse(withReader: reader)
        ensureString(ret.0, exp: "h🇨🇿w")
    }
    
    func testObject_Empty() {
        let reader = ByteReader(content: "{}")
        let ret = try! ValueParser().parse(withReader: reader)
        let exp: JsonObject = [:]
        ensureObject(ret.0, exp: exp)
    }
    
    func testObject_Example1() {
        let data = "{\t\"hello\" : \"wor🇨🇿ld\", \n\t \"val\": 1234, \"many\": [\n-12.32, null, \"yo\"\r], \"emptyDict\": {}, \"dict\": {\"arr\":[]}, \"name\": true}".chars()
        let reader = ByteReader(content: data)
        let ret = try! ValueParser().parse(withReader: reader)
        let exp: JsonObject = [
            "hello": JsonValue.String("wor🇨🇿ld"),
            "val": JsonValue.Number(.JsonInt(1234)),
            "many": JsonValue.Array([
                JsonValue.Number(.JsonDbl(-12.32)),
                JsonValue.Null,
                JsonValue.String("yo")
            ]),
            "emptyDict": JsonValue.Object([:]),
            "dict": JsonValue.Object([
                    "arr": JsonValue.Array([])
                ]),
            "name": JsonValue.Boolean(.True)
        ]
        ensureObject(ret.0, exp: exp)
    }
    
    func testObject_DirectReader_Example1() {
        let data = "{\t\"hello\" : \"wor🇨🇿ld\", \n\t \"val\": 1234, \"many\": [\n-12.32, null, \"yo\"\r], \"emptyDict\": {}, \"dict\": {\"arr\":[]}, \"name\": true}".chars()
        let reader = ByteReader(content: data)
        let ret = try! Jay().typesafeJsonFromReader(reader)
        let exp: JsonObject = [
                                  "hello": JsonValue.String("wor🇨🇿ld"),
                                  "val": JsonValue.Number(.JsonInt(1234)),
                                  "many": JsonValue.Array([
                                                              JsonValue.Number(.JsonDbl(-12.32)),
                                                              JsonValue.Null,
                                                              JsonValue.String("yo")
                                    ]),
                                  "emptyDict": JsonValue.Object([:]),
                                  "dict": JsonValue.Object([
                                                               "arr": JsonValue.Array([])
                                    ]),
                                  "name": JsonValue.Boolean(.True)
        ]
        ensureObject(ret, exp: exp)
    }
    
    func testNative_Example1() {
        let data = "{\t\"hello\" : \"wor🇨🇿ld\", \n\t \"val\": 1234, \"many\": [\n-12.32, \"yo\"\r], \"emptyDict\": {}, \"dict\": {\"arr\":[]}, \"name\": true}".chars()
        
        let ret = try! Jay().jsonFromData(data)
        let exp: [String: Any] = [
            "hello": "wor🇨🇿ld",
            "val": 1234,
            "many": [
                -12.32,
                // NSNull(), //add null testing back once we can compare arbitrary hierarchies, printing its descriptions gives different pointers for different NSNulls thus they don't compare as ==
                "yo"
            ] as [Any],
            "emptyDict": [String:Any](),
            "dict": [
                "arr": [Any]()
                ],
            "name": true
        ]
        let expStr = "\(exp)"
        let retStr = "\(ret)"
        XCTAssertEqual(expStr, retStr)
    }
    
    //https://twitter.com/schwa/status/706765578631979008
    func test_Example2() {
        let data = "[1,[2,[3]]]".chars()
        let ret = try! Jay().typesafeJsonFromData(data)
        let exp: JsonArray = [
            JsonValue.Number(JsonNumber.JsonInt(1)),
            JsonValue.Array([
                JsonValue.Number(JsonNumber.JsonInt(2)),
                JsonValue.Array([
                    JsonValue.Number(JsonNumber.JsonInt(3))
                ])
            ])
        ]
        ensureArray(ret, exp: exp)
    }
        
}

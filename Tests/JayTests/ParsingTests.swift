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

extension ParsingTests {
    static var allTests = [
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
        ("testTypesafe_Example1", testTypesafe_Example1),
        ("test_Example2", test_Example2)
    ]
}

class ParsingTests:XCTestCase {
    
    func testPrepareForReading_FailOnEmpty() {
        let reader = ByteReader(content: "")
        XCTAssertThrowsError(try prepareForReading(with: reader))
    }
    
    func testExtraTokensThrow() {
        let data = "{\"hello\":\"world\"} blah".chars()
        let ret = try? Parser().parseJsonFromData(data)
        XCTAssertNil(ret)
    }
    
    func testNull_Normal() {
        let reader = ByteReader(content: "null,   heyo")
        let ret = try! ValueParser().parse(with: reader)
        ensureNull(ret)
        XCTAssert(reader.curr() == ",".char())
    }
    
    func testNull_Mismatch() {
        
        let reader = ByteReader(content: "NAll")
        let ret = try? ValueParser().parse(with: reader)
        XCTAssertNil(ret)
    }
    
    //TODO: add names to linux manifest
    func testComment_SingleLine_EndedWithNewline() throws {
        
        let reader = ByteReader(content: "// hello world \n")
        let ret = try! CommentParser().parse(with: reader)
        try ensureComment(ret, exp: " hello world ")
    }
    
    func testComment_SingleLine_EndedReader() throws {
        
        let reader = ByteReader(content: "// hello")
        let ret = try! CommentParser().parse(with: reader)
        try ensureComment(ret, exp: " hello")
    }
    
    func testComment_MultiLine_ActuallySingleLine() throws {
        
        let reader = ByteReader(content: "/* hello world */")
        let ret = try! CommentParser().parse(with: reader)
        try ensureComment(ret, exp: " hello world ")
    }
    
    func testComment_MultiLine_ThreeLines() throws {
        
        let reader = ByteReader(content: "/*\n hello world \n*/")
        let ret = try! CommentParser().parse(with: reader)
        try ensureComment(ret, exp: "\n hello world \n")
    }
    
    func testAllIncludingComment_FromFile() throws {
        let bytes = loadFixture("withcomments")
        let reader = ByteReader(content: bytes)
        let ret = try Jay().jsonFromReader(reader)
        XCTAssertTrue(reader.isDone())
        ensureObject(ret, exp: [
                "message": .string("Hello world."),
                "other": .string("/* don't strip this out */"),
                "crazy": .string("\"/*wow escaped strings are*/ // annoying looking \""),
                "number": .number(.unsignedInteger(3))
            ])
    }
    
    func testBoolean_True_Normal() {
        
        let reader = ByteReader(content: "true, ")
        let ret = try! ValueParser().parse(with: reader)
        ensureBool(ret, exp: true)
        XCTAssert(reader.curr() == ",".char())
    }

    func testBoolean_True_Mismatch() {
        
        let reader = ByteReader(content: "tRue, ")
        let ret = try? ValueParser().parse(with: reader)
        XCTAssertNil(ret)
    }

    func testBoolean_False_Normal() {
        
        let reader = ByteReader(content: "false, ")
        let ret = try! ValueParser().parse(with: reader)
        ensureBool(ret, exp: false)
        XCTAssert(reader.curr() == ",".char())
    }
    
    func testBoolean_False_Mismatch() {
        
        let reader = ByteReader(content: "fals, ")
        let ret = try? ValueParser().parse(with: reader)
        XCTAssertNil(ret)
    }

    func testArray_NullsBoolsNums_Normal_Minimal_RootParser() {
        
        let reader = ByteReader(content: "[null,true,false,12,-10,-24.3,18.2e9]")
        let ret = try! RootParser().parse(with: reader)
        let exp: [JSON] = [
            JSON.null,
            JSON.boolean(true),
            JSON.boolean(false),
            JSON.number(.unsignedInteger(12)),
            JSON.number(.integer(-10)),
            JSON.number(.double(-24.3)),
            JSON.number(.double(18200000000)),
        ]
        ensureArray(ret, exp: exp)
        XCTAssert(reader.isDone())
    }

    func testArray_NullsBoolsNums_Normal_MuchWhitespace() {
        
        let reader = ByteReader(content: " \t[\n  null ,true, \n-12.3 , false\r\n]\n  ")
        let ret = try! ValueParser().parse(with: reader)
        let exp: [JSON] = [
            JSON.null,
            JSON.boolean(true),
            JSON.number(.double(-12.3)),
            JSON.boolean(false)
        ]
        ensureArray(ret, exp: exp)
        XCTAssert(reader.curr() == "\n".char())
    }
    
    func testArray_NullsAndBooleans_Bad_MissingEnd() {
        
        let reader = ByteReader(content: " \t[\n  null ,true, \nfalse\r\n\n  ")
        let ret = try? ValueParser().parse(with: reader)
        XCTAssertNil(ret)
    }
    
    func testArray_NullsAndBooleans_Bad_MissingComma() {
        
        let reader = ByteReader(content: " \t[\n  null true, \nfalse\r\n]\n  ")
        let ret = try? ValueParser().parse(with: reader)
        XCTAssertNil(ret)
    }
    
    func testArray_NullsAndBooleans_Bad_ExtraComma() {
        
        let reader = ByteReader(content: " \t[\n  null , , true, \nfalse\r\n]\n  ")
        let ret = try? ValueParser().parse(with: reader)
        XCTAssertNil(ret)
    }

    func testArray_NullsAndBooleans_Bad_TrailingComma() {
        
        let reader = ByteReader(content: " \t[\n  null ,true, \nfalse\r\n, ]\n  ")
        let ret = try? ValueParser().parse(with: reader)
        XCTAssertNil(ret)
    }

    func testNumber_Int_Zero() {
        let reader = ByteReader(content: "0  ")
        let ret = try! ValueParser().parse(with: reader)
        ensureNumber(ret, exp: JSON.Number.unsignedInteger(0))
    }
    
    func testNumber_Int_One() {
        let reader = ByteReader(content: "1  ")
        let ret = try! ValueParser().parse(with: reader)
        ensureNumber(ret, exp: JSON.Number.unsignedInteger(1))
    }

    func testNumber_Int_Basic() {
        let reader = ByteReader(content: "24  ")
        let ret = try! ValueParser().parse(with: reader)
        ensureNumber(ret, exp: JSON.Number.unsignedInteger(24))
    }
    
    func testNumber_Int_Negative() {
        let reader = ByteReader(content: "24 , ")
        let ret = try! ValueParser().parse(with: reader)
        ensureNumber(ret, exp: JSON.Number.unsignedInteger(24))
    }
    
    func testNumber_Dbl_Basic() {
        let reader = ByteReader(content: "24.34, ")
        let ret = try! ValueParser().parse(with: reader)
        ensureNumber(ret, exp: JSON.Number.double(24.34))
    }
    
    func testNumber_Dbl_ZeroSomething() {
        let reader = ByteReader(content: "0.34, ")
        let ret = try! ValueParser().parse(with: reader)
        ensureNumber(ret, exp: JSON.Number.double(0.34))
    }
    
    func testNumber_Dbl_MinusZeroSomething() {
        let reader = ByteReader(content: "-0.34, ")
        let ret = try! ValueParser().parse(with: reader)
        ensureNumber(ret, exp: JSON.Number.double(-0.34))
    }
    
    func testNumber_Dbl_Incomplete() {
        let reader = ByteReader(content: "24., ")
        let ret = try? ValueParser().parse(with: reader)
        XCTAssertNil(ret)
    }
    
    func testNumber_Dbl_Negative() {
        let reader = ByteReader(content: "-24.34]")
        let ret = try! ValueParser().parse(with: reader)
        ensureNumber(ret, exp: JSON.Number.double(-24.34))
    }
    
    func testNumber_Dbl_Negative_WrongChar() {
        let reader = ByteReader(content: "-24.3a4]")
        let ret = try? ValueParser().parse(with: reader)
        XCTAssertNil(ret)
    }

    func testNumber_Dbl_Negative_TwoDecimalPoints() {
        let reader = ByteReader(content: "-24.3.4]")
        let ret = try? ValueParser().parse(with: reader)
        XCTAssertNil(ret)
    }
    
    func testNumber_Dbl_Negative_TwoMinuses() {
        let reader = ByteReader(content: "--24.34]")
        let ret = try? ValueParser().parse(with: reader)
        XCTAssertNil(ret)
    }

    func testNumber_Double_Exp_Normal() {
        let reader = ByteReader(content: "-24.3245e2, ")
        let ret = try! ValueParser().parse(with: reader)
        ensureNumber(ret, exp: JSON.Number.double(-2432.45))
    }
    
    func testNumber_Double_Exp_Positive() {
        let reader = ByteReader(content: "-24.3245e+2, ")
        let ret = try! ValueParser().parse(with: reader)
        ensureNumber(ret, exp: JSON.Number.double(-2432.45))
    }
    
    func testNumber_Double_Exp_Negative() {
        let reader = ByteReader(content: "-24.3245e-2, ")
        let ret = try! ValueParser().parse(with: reader)
        ensureNumber(ret, exp: JSON.Number.double(-0.243245))
    }
    
    func testNumber_Double_Exp_NoFrac() {
        let reader = ByteReader(content: "24E2, ")
        let ret = try! ValueParser().parse(with: reader)
        ensureNumber(ret, exp: JSON.Number.double(2400))
    }

    func testNumber_Double_Exp_TwoEs() {
        let reader = ByteReader(content: "-24.3245eE2, ")
        let ret = try? ValueParser().parse(with: reader)
        XCTAssertNil(ret)
    }

    func testEscape_Unicode_Normal() {
        
        let reader = ByteReader(content: "\\u0048 ")
        let char = try! StringParser().unescapedCharacter(reader)
        
        XCTAssert(String(char) == "H")
    }
    
    func testEscape_Unicode_InvalidUnicode_MissingDigit() {
        
        let reader = ByteReader(content: "\\u048 ")
        XCTAssertNil(try? StringParser().unescapedCharacter(reader))
    }
    
    func testEscape_Unicode_InvalidUnicode_MissingAllDigits() {
        
        let reader = ByteReader(content: "\\u ")
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
        
        let reader = ByteReader(content: chars)
        var char: UnicodeScalar
        
        //regular
        
        char = try! StringParser().unescapedCharacter(reader)
        XCTAssert(try! Const.QuotationMark.string() == String(char))

        char = try! StringParser().unescapedCharacter(reader)
        XCTAssert(try! Const.ReverseSolidus.string() == String(char))

        char = try! StringParser().unescapedCharacter(reader)
        XCTAssert(try! Const.Solidus.string() == String(char))

        
        //rule-based
        
        char = try! StringParser().unescapedCharacter(reader)
        XCTAssert(try! Const.Backspace.string() == String(char))

        char = try! StringParser().unescapedCharacter(reader)
        XCTAssert(try! Const.FormFeed.string() == String(char))

        char = try! StringParser().unescapedCharacter(reader)
        XCTAssertEqual(try! Const.NewLine.string(), String(char))

        char = try! StringParser().unescapedCharacter(reader)
        XCTAssertEqual(try! Const.CarriageReturn.string(), String(char))

        char = try! StringParser().unescapedCharacter(reader)
        XCTAssertEqual(try! Const.HorizontalTab.string(), String(char))
    }
    
    func testString_Empty() {
        let reader = ByteReader(content: "\"\" ")
        let ret = try! ValueParser().parse(with: reader)
        ensureString(ret, exp: "")
    }
    
    func testString_Normal() {
        let reader = ByteReader(content: "\"hello world\" ")
        let ret = try! ValueParser().parse(with: reader)
        ensureString(ret, exp: "hello world")
    }
    
    func testString_Normal_WhitespaceInside() {
        let reader = ByteReader(content: "\"he \\r\\n l \\t l \\n o wo\\rrld \" ")
        let ret = try! ValueParser().parse(with: reader)
        ensureString(ret, exp: "he \r\n l \t l \n o wo\rrld ")
    }
    
    func testString_StartEndWithSpaces() {
        let reader = ByteReader(content: "\"  hello world    \" ")
        let ret = try! ValueParser().parse(with: reader)
        ensureString(ret, exp: "  hello world    ")
    }
    
    func testString_Unicode_RegularChar() {
        let reader = ByteReader(content: "\"hel\\u006co world\" ")
        let ret = try! ValueParser().parse(with: reader)
        ensureString(ret, exp: "hello world")
    }
    
    func testString_Unicode_SpecialCharacter_CoolA() {
        let reader = ByteReader(content: "\"h\\u01cdw\" ")
        let ret = try! ValueParser().parse(with: reader)
        ensureString(ret, exp: "hǍw")
    }

    func testString_Unicode_SpecialCharacter_HebrewShin() {
        let reader = ByteReader(content: "\"h\\u05e9w\" ")
        let ret = try! ValueParser().parse(with: reader)
        ensureString(ret, exp: "hשw")
    }
    
    func testString_Unicode_SpecialCharacter_QuarterTo() {
        let reader = ByteReader(content: "\"h\\u25d5w\" ")
        let ret = try! ValueParser().parse(with: reader)
        ensureString(ret, exp: "h◕w")
    }
    
    func testString_Unicode_SpecialCharacter_EmojiSimple() {
        let reader = ByteReader(content: "\"h\\ud83d\\ude3bw\" ")
        let ret = try! ValueParser().parse(with: reader)
        ensureString(ret, exp: "h😻w")
    }
    
    func testString_Unicode_SpecialCharacter_EmojiComplex() {
        let reader = ByteReader(content: "\"h\\ud83c\\udde8\\ud83c\\uddffw\" ")
        let ret = try! ValueParser().parse(with: reader)
        ensureString(ret, exp: "h🇨🇿w")
    }
    
    func testString_SpecialCharacter_QuarterTo() {
        let reader = ByteReader(content: "\"h◕w\" ")
        let ret = try! ValueParser().parse(with: reader)
        ensureString(ret, exp: "h◕w")
    }

    func testString_SpecialCharacter_EmojiSimple() {
        let reader = ByteReader(content: "\"h😻w\" ")
        let ret = try! ValueParser().parse(with: reader)
        ensureString(ret, exp: "h😻w")
    }

    func testString_SpecialCharacter_EmojiComplex() {
        let reader = ByteReader(content: "\"h🇨🇿w\" ")
        let ret = try! ValueParser().parse(with: reader)
        ensureString(ret, exp: "h🇨🇿w")
    }
    
    func testObject_Empty() {
        let reader = ByteReader(content: "{}")
        let ret = try! ValueParser().parse(with: reader)
        let exp: [String: JSON] = [:]
        ensureObject(ret, exp: exp)
    }
    
    func testObject_Example1() {
        let data = "{\t\"hello\" : \"wor🇨🇿ld\", \n\t \"val\": 1234, \"many\": [\n-12.32, null, \"yo\"\r], \"emptyDict\": {}, \"dict\": {\"arr\":[]}, \"name\": true}".chars()
        let reader = ByteReader(content: data)
        let ret = try! ValueParser().parse(with: reader)
        let exp: [String: JSON] = [
            "hello": JSON.string("wor🇨🇿ld"),
            "val": JSON.number(.unsignedInteger(1234)),
            "many": JSON.array([
                JSON.number(.double(-12.32)),
                JSON.null,
                JSON.string("yo")
            ]),
            "emptyDict": JSON.object([:]),
            "dict": JSON.object([
                    "arr": JSON.array([])
                ]),
            "name": JSON.boolean(true)
        ]
        ensureObject(ret, exp: exp)
    }
    
    func testObject_DirectReader_Example1() {
        let data = "{\t\"hello\" : \"wor🇨🇿ld\", \n\t \"val\": 1234, \"many\": [\n-12.32, null, \"yo\"\r], \"emptyDict\": {}, \"dict\": {\"arr\":[]}, \"name\": true}".chars()
        let reader = ByteReader(content: data)
        let ret = try! Jay().jsonFromReader(reader)
        let exp: [String: JSON] = [
                                  "hello": JSON.string("wor🇨🇿ld"),
                                  "val": JSON.number(.unsignedInteger(1234)),
                                  "many": JSON.array([
                                                              JSON.number(.double(-12.32)),
                                                              JSON.null,
                                                              JSON.string("yo")
                                    ]),
                                  "emptyDict": JSON.object([:]),
                                  "dict": JSON.object([
                                                               "arr": JSON.array([])
                                    ]),
                                  "name": JSON.boolean(true)
        ]
        ensureObject(ret, exp: exp)
    }
    
    func testNative_Example1() {
        let data = "{\t\"hello\" : \"wor🇨🇿ld\", \n\t \"val\": 1234, \"many\": [\n-12.32, \"yo\"\r], \"emptyDict\": {}, \"dict\": {\"arr\":[]}, \"name\": true}".chars()
        
        let ret = try! Jay().anyJsonFromData(data)
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
    
    func testTypesafe_Example1() {
        let data = "{\t\"hello\" : \"wor🇨🇿ld\", \n\t \"val\": 1234, \"many\": [\n-12.32, null, \"yo\"\r], \"emptyDict\": {}, \"dict\": {\"arr\":[]}, \"name\": true}".chars()
        
        let ret = try! Jay().jsonFromData(data)
        let exp: JSON = .object([
            "hello": .string("wor🇨🇿ld"),
            "val": .number(.unsignedInteger(1234)),
            "many": .array([
                .number(.double(-12.32)),
                .null,
                .string("yo")
                ]),
            "emptyDict": .object([:]),
            "dict": .object([
                "arr": .array([])
            ]),
            "name": .boolean(true)
        ])
        XCTAssertEqual(exp, ret)
    }

    //https://twitter.com/schwa/status/706765578631979008
    func test_Example2() {
        let data = "[1,[2,[3]]]".chars()
        let ret = try! Jay().jsonFromData(data)
        let exp: [JSON] = [
            JSON.number(.unsignedInteger(1)),
            JSON.array([
                JSON.number(.unsignedInteger(2)),
                JSON.array([
                    JSON.number(.unsignedInteger(3))
                ])
            ])
        ]
        ensureArray(ret, exp: exp)
    }
        
}

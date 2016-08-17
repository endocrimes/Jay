//
//  ReaderTests.swift
//  Jay
//
//  Created by Honza Dvorsky on 2/17/16.
//  Copyright © 2016 Honza Dvorsky. All rights reserved.
//

import XCTest
@testable import Jay

extension ReaderTests {
    static var allTests = [
        ("testConsumingWhitespace_Normal", testConsumingWhitespace_Normal),
        ("testConsumingWhitespace_NoWhitespace", testConsumingWhitespace_NoWhitespace),
        ("testConsumingWhitespace_Empty", testConsumingWhitespace_Empty),
        ("testStopAtFirstDifference_RegularMismatch", testStopAtFirstDifference_RegularMismatch),
        ("testStopAtFirstDifference_EmptyMain", testStopAtFirstDifference_EmptyMain),
        ("testStopAtFirstDifference_EmptyExpected", testStopAtFirstDifference_EmptyExpected),
        ("testStopAtFirstDifference_Normal", testStopAtFirstDifference_Normal),
        ("testReadNext_EnoughAvailable", testReadNext_EnoughAvailable),
        ("testReadNext_LessAvailable", testReadNext_LessAvailable)
    ]
}

class ReaderTests: XCTestCase {

    func testConsumingWhitespace_Normal() throws {
        
        let reader = ByteReader(content: " \n  \t \r  lala ")
        let consumed = try reader.consumeWhitespace()
        XCTAssertEqual(consumed, 9)
        XCTAssert(reader.curr() == "l".char())
    }
    
    func testConsumingWhitespace_NoWhitespace() throws {
        
        let reader = ByteReader(content: "lala ")
        let consumed = try reader.consumeWhitespace()
        XCTAssertEqual(consumed, 0)
        XCTAssert(reader.curr() == "l".char())
    }
    
    func testConsumingWhitespace_Empty() throws {
        
        let reader = ByteReader(content: "")
        let consumed = try reader.consumeWhitespace()
        XCTAssertEqual(consumed, 0)
        XCTAssertTrue(reader.isDone())
    }
    
    func testStopAtFirstDifference_RegularMismatch() {
        
        //regular mismatch case
        let mainReader = ByteReader(content: "hello")
        let expectedReader = ByteReader(content: "hearing")
        do {
            try mainReader.stopAtFirstDifference(expectedReader)
            XCTFail()
        } catch JayError.mismatch(let main, let other) {
            
            XCTAssert(!main.isDone())
            XCTAssert(!other.isDone())
            XCTAssert(main.curr() == "l".char())
            XCTAssert(other.curr() == "a".char())
        } catch {
            XCTFail()
        }
    }

    func testStopAtFirstDifference_EmptyMain() {
        
        //regular mismatch case
        let mainReader = ByteReader(content: "")
        let expectedReader = ByteReader(content: "hearing")
        do {
            try mainReader.stopAtFirstDifference(expectedReader)
            XCTFail()
        } catch JayError.mismatch(let main, let other) {
            XCTAssert(main.isDone())
            XCTAssert(!other.isDone())
            XCTAssert(other.curr() == "h".char())
        } catch {
            XCTFail()
        }
    }

    func testStopAtFirstDifference_EmptyExpected() {
        
        //regular mismatch case
        let mainReader = ByteReader(content: "hello")
        let expectedReader = ByteReader(content: "")
        do {
            try mainReader.stopAtFirstDifference(expectedReader)
        } catch {
            XCTFail()
        }
    }
    
    func testStopAtFirstDifference_Normal() {
        
        //regular mismatch case
        let mainReader = ByteReader(content: "hello world")
        let expectedReader = ByteReader(content: "hello w")
        do {
            try mainReader.stopAtFirstDifference(expectedReader)
            XCTAssert(!mainReader.isDone())
            XCTAssert(mainReader.curr() == "o".char())
        } catch {
            XCTFail()
        }
    }
    
    func testReadNext_EnoughAvailable() {
        let mainReader = ByteReader(content: "hello world")
        _ = try! mainReader.readNext(2)
        let next = try! mainReader.readNext(5)
        XCTAssert(next == "llo w".chars())
        XCTAssert(mainReader.curr() == "o".char())
    }
    
    func testReadNext_LessAvailable() {
        let mainReader = ByteReader(content: "hello world")
        XCTAssertNil(try? mainReader.readNext(12))
    }

}

//
//  ReaderTests.swift
//  Jay
//
//  Created by Honza Dvorsky on 2/17/16.
//  Copyright © 2016 Honza Dvorsky. All rights reserved.
//

import XCTest

class ReaderTests: XCTestCase {

    func testConsumingWhitespace() {
        
        var reader = ByteReader(content: " \n  \t \r  lala ")
        var consumed = reader.consumeWhitespace()
        XCTAssertEqual(consumed, 9)
        XCTAssert(reader.curr() == "l".cchars().first!)
        
        reader = ByteReader(content: "lala ")
        consumed = reader.consumeWhitespace()
        XCTAssertEqual(consumed, 0)
        XCTAssert(reader.curr() == "l".cchars().first!)
        
        reader = ByteReader(content: "")
        consumed = reader.consumeWhitespace()
        XCTAssertEqual(consumed, 0)
        XCTAssertTrue(reader.isDone())
    }
    
    func testStopAtFirstDifference() {
        
        
        
    }
}

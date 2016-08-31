//
//  Parser.swift
//  Jay
//
//  Created by Honza Dvorsky on 2/17/16.
//  Copyright © 2016 Honza Dvorsky. All rights reserved.
//

struct Parser {
    
    //give any Reader-conforming object
    func parseJsonFromReader<R: Reader>(_ reader: R) throws -> JSON {
        
        //delegate parsing
        let json = try RootParser().parse(with: reader)
        
        if !reader.finishParsingWhenValid() {
            //skip whitespace and ensure no more tokens are present, otherwise throw
            try reader.consumeWhitespace()
            guard reader.isDone() else {
                throw JayError.extraTokensFound(reader)
            }
        }
        
        return json
    }
}

extension Parser {
    
    //assuming data [Int8]
    func parseJsonFromData(_ data: [JChar]) throws -> JSON {
        return try parseJsonFromReader(ByteReader(content: data))
    }
}

protocol JsonParser {
    func parse<R: Reader>(with reader: R) throws -> JSON
}

//MARK: Utils

func prepareForReading<R: Reader>(with reader: R) throws {
    
    try reader.ensureNotDone()

    var changed = false
    let commentParser = CommentParser()
    repeat {
        
        //reset state
        changed = false
        
        //ensure there are no comments
        if reader.curr() == Const.Solidus {
            let comments = try commentParser.parse(with: reader)
            changed = changed || !comments.isEmpty
        }
        
        //ensure no leading whitespace
        let consumedWhitespaceCount = try reader.consumeWhitespace()
        changed = changed || consumedWhitespaceCount > 0
        
        //if no more chars, then we encountered an unexpected end
        try reader.ensureNotDone()
        
    } while changed
}


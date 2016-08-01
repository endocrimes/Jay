//
//  Parser.swift
//  Jay
//
//  Created by Honza Dvorsky on 2/17/16.
//  Copyright © 2016 Honza Dvorsky. All rights reserved.
//

struct Parser {
    
    //give any Reader-conforming object
    static func parseJsonFromReader<R: Reader>(_ reader: R) throws -> JSON {
        
        //delegate parsing
        let json = try RootParser.parse(with: reader)
        
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
    static func parseJsonFromData(_ data: [JChar]) throws -> JSON {
        let reader = ByteReader(content: data)
        let json = try parseJsonFromReader(reader)
        return json
    }
}

protocol JsonParser {
    static func parse<R: Reader>(with reader: R) throws -> JSON
}

extension JsonParser {

    //MARK: Utils
    
    static func prepareForReading(with reader: Reader) throws {
        
        //ensure no leading whitespace
        try reader.consumeWhitespace()
        
        //if no more chars, then we encountered an unexpected end
        try reader.ensureNotDone()
    }
}


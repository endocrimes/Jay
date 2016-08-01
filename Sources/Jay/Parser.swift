//
//  Parser.swift
//  Jay
//
//  Created by Honza Dvorsky on 2/17/16.
//  Copyright © 2016 Honza Dvorsky. All rights reserved.
//

struct Parser {
    
    //give any Reader-conforming object
    func parseJsonFromReader(_ reader: Reader) throws -> JSON {
        
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
    func parse(with reader: Reader) throws -> JSON
}

extension JsonParser {

    //MARK: Utils
    
    func prepareForReading(with reader: Reader) throws {
        
        //ensure no leading whitespace
        try reader.consumeWhitespace()
        
        //if no more chars, then we encountered an unexpected end
        try reader.ensureNotDone()
    }
}

